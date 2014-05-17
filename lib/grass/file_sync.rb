require 'fileutils'

module Grass
  
  module FileSync
    
    class FileProxy
    
      def initialize source
        @source = source
        FileUtils.mkdir_p File.dirname(@source.filepath)
        exists? ? read : write(@source.raw)
      end
      
      def exists?
        File.exists? @source.filepath
      end
    
      def read
        begin
          value = File.read(@source.filepath)
          @source.update(raw: value) if dirty?
          value
        end rescue nil
      end
      
      def write value
        begin
          File.open(@source.filepath,File::RDWR|File::CREAT){ |f| 
            f.truncate(0); f.rewind; f.write(value)
          }
          value
        end rescue nil
      end 
      
      def delete
        File.delete(@source.filepath) rescue nil
      end
      
      def dirty?
        @source.raw.nil? || File.mtime(@source.filepath).to_i > @source.updated_at.to_i
      end
      
    end
    
    def self.included(base)
      base.send :after_initialize, :init_file, if: 'binary.nil?'
      base.send :before_save, :write_file, if: 'binary.nil?'
      base.send :after_destroy, :delete_file, if: 'binary.nil?'
    end
    
    attr_reader :file
    
    private
    
    def init_file
      @file = FileProxy.new(self)
    end
    
    def delete_file
      @file.delete
    end
    
    def write_file
      @file.write(self.raw)
    end
    
  end
  
end