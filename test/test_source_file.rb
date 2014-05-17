require 'minitest_helper'
require 'grass/source'

module Grass
  
  class TestSourceFile < Minitest::Test
    
    def setup
      I18n.default_locale = :en
      I18n.available_locales = [:en,:es]
      @source2 = Source.create!(key: Key.new(id: "/texts/sourcekey2_#{Time.now.to_f.to_s.gsub('.','_')}" ), raw: "Hello")      
    end
    
    def teardown
      @source2.destroy!
    end
    
    def test_file_exists?
      assert @source2.file.exists?
    end
 
    def test_file_read
      assert_equal "Hello", @source2.file.read
    end  
    
    def test_file_write
      @source2.file.write "Bye"
      assert_equal "Bye", @source2.file.read
    end   
    
    def test_file_write_sync
      @source2.write "Hello Again"
      assert_equal "Hello Again", @source2.file.read
    end
    
    def test_file_read_sync
      sleep 1      

      File.open(@source2.filepath,File::RDWR|File::CREAT){ |f| 
        f.truncate(0); f.rewind; f.write("Hello Other")
      }      
  
      assert_equal "Hello Other", @source2.reload.read
    end    
    
  end
end