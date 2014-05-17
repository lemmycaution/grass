require 'grass/render/renderer'
require 'grass/render/view'
require 'tilt/redcarpet'

module Grass
  module Render
    class Page    

      include Renderer
      
      def render          
        if @data[:view].nil? && !self.view.nil?
          @data[:view] = @view
          @data[:source] = @source
          @view.render @data
        else
          super
        end        
      end
      
      def view
        @view ||= begin
          keys = ["/views/#{@source.dir}/#{@source.path}","/views/#{@source.dir}/#{Grass::Render::View::DEFAULT_VIEW}"]
          Source[keys].first
          # keys.map{|id| Source.find_by(key: Key.new(id: id))}.compact.first
        end
      end
  
    end
  end
end