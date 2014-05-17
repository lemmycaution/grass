module Goliath
  module Rack
    class SecureHeaders
      
      include Goliath::Rack::AsyncMiddleware
      
      HEADERS = {
        'X-Frame-Options' => 'SAMEORIGIN',
        'X-XSS-Protection' => '1; mode=block',
        'X-Content-Type-Options' => 'nosniff'
      }
      
      def post_process(env, status, headers, body)
        headers.update HEADERS
        [status, headers, body]
      end
      
    end
  end
end