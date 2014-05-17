require 'grass/source'

module Grass
  module Helpers
    
    module RenderHelper
  
      def include_partial key
        source = Source[key].first || init_source_if_file_exists(key)
        source.try(:raw)
      end
  
      def render_partial key, data = nil
        data ||= @data
        source = Source[key].first || init_source_if_file_exists(key)
        source.try(:render,data)
      end 
      
      def render_content
        @data[:source].try(:render,@data)
      end
  
      private
      
      def init_source_if_file_exists key
        key = Grass::Key.new(id: key)
        return unless File.exists?(key.filepath)
        source = Grass::Source.find_or_create_by!(filepath: key.filepath)
        source.raw = File.read(source.filepath)
        source.commit!
        source
      end
    end
  end
end