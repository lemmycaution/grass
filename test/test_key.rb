require 'minitest_helper'
require 'grass/key'
module Grass
  
  class TestKey < Minitest::Test
    
    def setup
      I18n.default_locale = :en
      I18n.available_locales = [:en,:es]
    end
    
    ##
    # Template Keys
    
    def test_new_with_locale
      key = Key.new(id: "/es/views/test" )
      assert key.valid?
      assert_equal "/views/test", key.id        
      assert_equal "es", key.locale      
      assert_equal "views", key.dir
      assert_equal "test", key.path
      assert_equal "html", key.format      
      assert_equal nil, key.handler
      assert_equal "#{Grass.app_root}/views/test.es.html", key.filepath           
    end
        
    def test_new_layout
      key = Key.new(id: "/en/views/layouts/application.html.erb" )
      assert key.valid?
      assert_equal "/views/layouts/application", key.id              
      assert_equal "en", key.locale      
      assert_equal "views/layouts", key.dir
      assert_equal "application", key.path
      assert_equal "html", key.format
      assert_equal "erb", key.handler  
      assert_equal "#{Grass.app_root}/views/layouts/application.en.html.erb", key.filepath
    end
    
    ##
    # Asset Keys
    
    def test_assets
      key = Key.new(id: "/es/stylesheets/app.css" )
      assert key.valid?
      assert_equal "/stylesheets/app", key.id              
      assert_equal 'es', key.locale
      assert_equal "stylesheets", key.dir
      assert_equal "app", key.path
      assert_equal "css", key.format
      assert_equal nil, key.handler  
      assert_equal "#{Grass.app_root}/assets/stylesheets/app.es.css", key.filepath
    end
    
    def test_assets_js
      key = Key.new(id: "/scripts/app.js.coffee.erb" )
      assert key.valid?      
      assert_equal "/scripts/app", key.id              
      assert_equal 'en', key.locale
      assert_equal "scripts", key.dir
      assert_equal "app", key.path
      assert_equal "js", key.format
      assert_equal "coffee.erb", key.handler  
      assert_equal "#{Grass.app_root}/assets/scripts/app.en.js.coffee.erb", key.filepath
    end
    
    def test_assets_with_filepath
      key = Key.new(filepath: "#{Grass.app_root}/scripts/app.en.js.coffee.erb" )
      assert key.valid?  
      assert_equal "/scripts/app", key.id              
      assert_equal 'en', key.locale
      assert_equal "scripts", key.dir
      assert_equal "app", key.path
      assert_equal "js", key.format
      assert_equal "coffee.erb", key.handler  
      assert_equal "#{Grass.app_root}/assets/scripts/app.en.js.coffee.erb", key.filepath
    end
    
    ##
    #Content Keys
    
    def test_with_external_filepath
      key = Key.new(filepath: "/var/www/grosartik/app/content/pages/test.es.htm.haml" )
      assert key.valid?
      assert_equal "/pages/test", key.id              
      assert_equal "es", key.locale      
      assert_equal "pages", key.dir
      assert_equal "test", key.path
      assert_equal "htm", key.format
      assert_equal "haml", key.handler  
      assert_equal "#{Grass.app_root}/content/pages/test.es.htm.haml", key.filepath
    end
    
    def test_new
      key = Key.new(id: "/texts/test.txt.str" )
      assert key.valid?
      assert_equal "/texts/test", key.id        
      assert_equal "en", key.locale      
      assert_equal "texts", key.dir
      assert_equal "test", key.path
      assert_equal "txt", key.format
      assert_equal 'str', key.handler 
      assert_equal "#{Grass.app_root}/content/texts/test.en.txt.str", key.filepath     
    end
    
    def test_new_with_handler_and_format
      key = Key.new(id: "/es/pages/test.htm.haml" )
      assert key.valid?
      assert_equal "/pages/test", key.id              
      assert_equal "es", key.locale      
      assert_equal "pages", key.dir
      assert_equal "test", key.path
      assert_equal "htm", key.format
      assert_equal "haml", key.handler  
      assert_equal "#{Grass.app_root}/content/pages/test.es.htm.haml", key.filepath
    end
    
  end
end