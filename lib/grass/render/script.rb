require 'grass/render/renderer'
require 'tilt/coffee'
require 'uglifier'

module Grass
  module Render
    class Script    

      JS = Uglifier.new
      
      include Renderer    
         
      def render 
        compress(super)
      end
  
      def compress source
        compressor.compress(source)
      end
  
      def compressor
        JS
      end
  
    end
  end
end