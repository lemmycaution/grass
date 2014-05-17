require 'goliath/api'
require 'json'
require 'grass'
require 'grass/source'
require 'grass/goliath/rack/secure_headers'

module Grass
  
  class API < Goliath::API
    use Goliath::Rack::SecureHeaders     
    use Goliath::Rack::Params
    use Goliath::Rack::Render
    use Goliath::Rack::Favicon, "#{Grass.root}/public/favicon.ico"
    
    JSON_HEAD = {"Content-Type" => "application/json"}
    FILE_PARAMS = %w(raw binary)
    FILE_ACTIONS = %w(hide show commit)
        
    def response(env)
      self.public_send env['REQUEST_METHOD'].downcase, env
    end

    def get(env)
      [200,JSON_HEAD,get_file.to_json]
    end    
    
    def post(env)
      file = Source.create(get_file_params.update(key: env['REQUEST_PATH']))
      error! file unless file.persisted?
      get_file_actions.each{|action| file.public_send(action) }
      [200,JSON_HEAD,file.to_json]      
    end
    
    def put(env)
      file = get_file
      updated = file.update(get_file_params)
      error! file unless updated
      get_file_actions.each{|action| file.public_send(action) }
      [200,JSON_HEAD,file.to_json]
    end
    
    def delete(env)
      file = get_file
      deleted = !file.destroy.persisted?
      error! file unless deleted
      [200,JSON_HEAD,deleted]
    end    
    
    private

    def get_file 
      raise Goliath::Validation::NotFoundError unless file = Source[env['REQUEST_PATH']].first
      file
    end
    
    def get_file_actions
      FILE_ACTIONS.select{ |action| params.delete(action) }.map{|action| "#{action}!" }
    end
    
    def get_file_params
      params.select{ |key,value| FILE_PARAMS.include?(key) }
    end
    
    def error! file
      raise Goliath::Validation::NotAcceptable.new(file.errors.full_messages.to_json)
    end
    
  end
  
end