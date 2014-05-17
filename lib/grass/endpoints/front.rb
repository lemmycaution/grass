require 'goliath/api'
require 'json'
require 'grass'
require 'grass/key'
require 'grass/source'
require 'grass/helpers/i18n_helper'
require 'grass/goliath/rack/secure_headers'
require 'grass/goliath/rack/cache'
require 'active_support/inflector'

module Grass
  
  class Front < Goliath::API
    
    module Helper
      def request_data
        {
          language_info: language_info(), 
          country_info: country_info(), 
          params: params,           
          http_host: env['HTTP_HOST'], 
          request_path: env["REQUEST_PATH"]
        }
      end
    end
    
    DEFAULT_PAGE = ENV['DEFAULT_PAGE'] || "index"
    
    include Helpers::I18nHelper
    include Helper
    
    Dir.glob("#{Grass.app_root}/helpers/*.rb").each do |file|
      require file
      include File.basename(file,".rb").classify.constantize
    end
    
    use Goliath::Rack::SecureHeaders     
    use Goliath::Rack::Params
    use Goliath::Rack::Render
    use Goliath::Rack::Validation::RequestMethod, %w(GET)
    use(Rack::Static,
    :root => "#{Grass.root}/public",
    :urls => Dir.glob("#{Grass.root}/public/*").map{|file| "/#{::File.basename(file)}" },
    :cache_control => ENV['CACHE_CONTROL'] || "no-cache")
    use Goliath::Rack::Cache     
        
    def response(env)
      self.public_send env['REQUEST_METHOD'].downcase, env
    end

    def get(env)
      
      set_locale

      id = get_id
      
      data = request_data
      
      headers = {}
      
      return fresh(id,data) if Grass.env == "development" && !config['enable_cache_for_development']

      # try memcache or render freshly
      if cached_response = Source.read_cache(Source.generate_cachekey(id,data))

        mime_type, body = cached_response
        headers = {"Content-Type" => mime_type}     
        status = 200   
          
      else
        status, headers, body = fresh(id,data)
        
      end
      
      [status,headers,body]

    end    
    
    private

    def get_id
      # set default home
      id = env["REQUEST_PATH"] == "/" ? "/pages/#{DEFAULT_PAGE}" : env["REQUEST_PATH"]

      # remove trailing slash
      id = id[0..-2] if id.end_with?("/")

      # ensure locale
      unless id =~ /#{Key::KEY_REGEX[:locale]}/      
        id = "/#{I18n.locale}/#{id}"
      end

      # add pages as default collection
      unless id =~ /#{Key::KEY_REGEX[:dir]}/      
        id = id.split("/").insert(2,"pages").join("/") 
      end

      id.gsub("//","/")
    end

    def get_file key
      raise Goliath::Validation::NotFoundError unless source = Source[key].first
      if Grass.env == "development"
        source.file.read 
        source.commit!
      end
      source
    end
    
    def fresh id, data = nil
      file = get_file(id)
      if file.type == "page"   
        file.render(data) 
        file.cache!
      end
      [200, {"Content-Type" => file.mime_type} ,file.read]
    end
    
  end
  
end