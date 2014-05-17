require 'minitest_helper'
require 'grass/source'

module Grass
  
  class TestSource < Minitest::Test
    
    def setup
      I18n.default_locale = :en
      I18n.available_locales = [:en,:es]
      
      @source = Source.create!(key: Key.new(id: "/texts/sourcekey_#{Time.now.to_f.to_s.gsub('.','_')}"), raw: "Hello")

    end
    
    def teardown
      @source.destroy!
    end
    
    def test_persisted?
      assert @source.persisted?
    end
    
    def test_find
      source = Source.find_by(keyid: @source.keyid)
      assert_equal source.as_json, @source.as_json

      source = Source[@source.keyid].first
            
      assert_equal source.as_json, @source.as_json      
    end
    
    def test_read
      assert_equal "Hello", @source.read
    end
    
    def test_write
      @source.write("Hello World")
      assert_equal "Hello World", @source.read
    end  
    
    def test_binary
      file = Source.create!(key: "/images/test.jpg", binary: IO.binread("#{Grass.gem_root}/test/support/test.jpg"))
      refute_nil file.binary
      assert_equal file.read, file.binary
      assert_equal file.mime_type, "image/jpeg"
      file.destroy!
    end
    
  end
end