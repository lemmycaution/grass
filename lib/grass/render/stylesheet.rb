require 'grass/render/yui_renderer'
require 'tilt/sass'

module Grass
  module Render
    class Stylesheet    

      include YuiRenderer       
      def compressor; CSS end
  
    end
  end
end