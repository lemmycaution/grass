require 'tilt'
require 'tilt/plain'
require 'tilt/string'
require 'tilt/erb'
require 'grass/helpers/render_helper'

Tilt.register Tilt::ERBTemplate, 'html'
Tilt.register Tilt::StringTemplate, 'txt'

module Grass
  module Render
    module Renderer     

      include Grass::Helpers::RenderHelper
  
      def initialize source, data = {}
        @source = source
        @data = data
      end

      def render 
        result = @source.raw
        templates.each do |template|
          result = template.new{result}.render(self,@data)
        end
        result
      end

      def templates 
        @templates ||= Tilt.templates_for(@source.handler || @source.format)
      end
  
    end
  end
end