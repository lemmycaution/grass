module Goliath
  module Rack
    class AuthBarrier
      
      include Goliath::Rack::BarrierAroundware
      include Goliath::Validation
      
      attr_reader   :db # Memcache Client
      attr_accessor :access_token
      
      class MissingApikeyError     < BadRequestError   ; end
      class InvalidApikeyError     < UnauthorizedError ; end
      
      def initialize(env, db_name)
        @db = env.config[db_name]
        super(env)
      end
      
      def pre_process
        env.trace('pre_process_beg')
        validate_apikey!

        # the results of the afirst deferrable will be set right into access_token (and the request into successes)
        get_access_token

        # On non-GET non-HEAD requests, we have to check auth now.
        unless lazy_authorization?
          perform     # yield execution until user_info has arrived
          check_authorization!
        end

        env.trace('pre_process_end')
        return Goliath::Connection::AsyncResponse
      end
      
      def post_process
        env.trace('post_process_beg')
        # [:access_token, :status, :headers, :body].each{|attr| env.logger.info(("%23s\t%s" % [attr, self.send(attr).inspect[0..200]])) }

        # inject_headers

        # We have to check auth now, we skipped it before
        if lazy_authorization?
          check_authorization!
        end

        env.trace('post_process_end')
        [status, headers, body]
      end

      def lazy_authorization?
        (env['REQUEST_METHOD'] == 'GET') || (env['REQUEST_METHOD'] == 'HEAD')
      end
      
      def get_access_token 
        @access_token = db.get(apikey_path) rescue nil
        # puts "GET KEY #{apikey_path.inspect} -> #{@access_token.inspect}"
        @access_token
      end
      
      def accept_response(handle, *args)
        env.trace("received_#{handle}")
        super(handle, *args)
      end
      
      # =======================================================================

      def validate_apikey!
        raise MissingApikeyError.new("Missing Api Key") if apikey.to_s.empty?
      end

      def check_authorization!
        unless access_token && account_valid?
          raise InvalidApikeyError.new("Invalid Api Key")
        else
          renew_token
        end
      end
      
      def apikey
        env.params['apikey']
      end
      
      def apikey_path
        Arms::Auth.keypath(apikey)
      end
      
      def account_valid?
        # puts "VALID? #{Digest::MD5.hexdigest(apikey) == access_token[:token]},#{account_belongs_to_host?},#{Arms::Auth.can?(access_token[:mode],env['REQUEST_METHOD'])}"
        # is token or key altered?
        Digest::MD5.hexdigest(apikey) == access_token[:token] && 
        # is on right host?
        account_belongs_to_host? &&
        # mode is able to do HTTP VERB?
        Arms::Auth.can?(access_token[:mode],env['REQUEST_METHOD'])
      end
      
      def renew_token
        db.touch apikey_path, Arms::Auth::TTLS[access_token[:mode]] unless access_token[:ttl].nil?
      end
      
      def account_belongs_to_host?
        return true if access_token[:mode] == Arms::Auth::ADMIN
        [access_token[:hosts]].flatten.join(",") =~ /#{env['HTTP_ORIGIN'] || env['SERVER_NAME']}/
      end
          
    end
  end
end