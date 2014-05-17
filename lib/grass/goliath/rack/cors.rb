require 'goliath/rack'

module Goliath
  module Rack
    class Cors
      include Goliath::Rack::AsyncMiddleware
      
      DEFAULT_OPTIONS = {
        :origin => '*',
        :methods => 'GET',
        :headers => 'Accept, Authorization, Content-Type, Origin',
        :expose_headers => 'Cache-Control, Content-Language, Content-Type, Expires, Last-Modified, Location, Pragma'
      }

      def initialize(app, options = {})
        super(app)
        @options = DEFAULT_OPTIONS.merge(options)
      end

      def call(env)
        if env['REQUEST_METHOD'] == 'OPTIONS'
          [200, cors_headers, []]
        else
          super(env)
        end
      end

      def post_process(env, status, headers, body)
        [status, cors_headers.merge(headers), body]
      end

      private

        def cors_headers
          headers = {}
          headers['Access-Control-Allow-Origin'] = @options[:origin]
          headers['Access-Control-Allow-Methods'] = @options[:methods]
          headers['Access-Control-Allow-Headers'] = @options[:headers]
          headers['Access-Control-Expose-Headers'] = @options[:expose_headers]
          headers
        end

    end
  end
end
