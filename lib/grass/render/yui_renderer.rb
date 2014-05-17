require "yui/compressor"
require 'grass/render/renderer'
module Grass
  module Render
    module YuiRenderer
      
      include Renderer
      
      YUI_JAR_FILE = "#{Grass.gem_root}/vendor/yuicompressor-2.4.8.jar"
      CSS = YUI::CssCompressor.new({jar_file: YUI_JAR_FILE})
      JS  = YUI::JavaScriptCompressor.new({jar_file: YUI_JAR_FILE, munge: true})
          
      def render 
        compress(super)
      end
  
      def compress source
        compressor.compress(source)
      end
  
      def compressor
        raise NotImplementedError
      end
      
    end
  end
end