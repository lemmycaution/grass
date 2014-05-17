require 'grass/render/renderer'

module Grass
  module Render
    class View    

      DEFAULT_LAYOUT = "application"
      DEFAULT_VIEW   = "show"
      
      include Renderer
  
      def render    
        if @data[:layout].nil? && !self.layout.nil?
          @data[:layout] = @layout
          templates.last.new{ @layout.raw }.render(self,@data) { super }
        else
          super
        end
      end
    
      def layout
        @layout ||= begin
          keys = ["/views/layouts/#{DEFAULT_LAYOUT}"]
          unless @data[:source].nil?
            keys.unshift "/views/layouts/#{@data[:source].dir}/#{@data[:source].path}",
            "/views/layouts/#{@data[:source].dir}/#{DEFAULT_VIEW}"
          end
          Source[keys].first
        end
      end
      
    end
  end
end