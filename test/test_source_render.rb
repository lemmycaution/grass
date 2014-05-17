require 'minitest_helper'
require 'grass/source'

module Grass
  
  class TestSourceRender < Minitest::Test
    
    def setup
      I18n.default_locale = :en
      I18n.available_locales = [:en,:es]
    end
    
    def test_render_text
      text = Source.create!(key: Key.new(id: "/texts/textkey" ), raw: 'Hello #{name}')
      assert_equal "Hello Bob", text.render(name: "Bob")
      text.destroy!
    end   
    
    def test_render_view
      text = Source.create!(key: Key.new(id: "/texts/partialtext1" ), raw: 'Dear #{name}')      
      layout = Source.create!(key: Key.new(id: "/views/layouts/application" ), raw: '<%= title %> <%= yield %>')            
      view = Source.create!(key: Key.new(id: "/views/viewkey1" ), raw: 'Hello <%= render_partial("/texts/partialtext1") %>')
      assert_equal "Page Title Hello Dear Bob", view.render(name: "Bob", title: "Page Title")
      view.destroy!
      text.destroy!
      layout.destroy!
    end   
    
    def test_render_page
      text = Source.create!(key: Key.new(id: "/texts/partialtext2" ), raw: 'Dear #{name}')      
      layout = Source.create!(key: Key.new(id: "/views/layouts/pages/show" ), raw: '<%= yield %>')            
      view = Source.create!(key: Key.new(id: "/views/pages/show" ), raw: 'Hello <%= render_partial("/texts/partialtext2", {name: "Bob"}) %>')
      page = Source.create!(key: Key.new(id: "/pages/page1" ), raw: '<%= render_content %>')      
      assert_equal "Hello Dear Bob", page.render
      view.destroy!
      text.destroy!
      layout.destroy!
      page.destroy!
    end
    
    def test_render_stylesheet
      style = Source.create!(key: Key.new(id: "/stylesheets/style1.scss" ), raw: 'body{h1{color:red}}')      
      assert_equal "body h1{color:red}", style.render
      style.destroy!
    end
    
    def test_render_script
      script = Source.create!(key: Key.new(id: "/scripts/style1.js.coffee" ), raw: 'console.log "hello"')      
      assert_equal '(function(){console.log("hello")}).call(this);', script.render
      script.destroy!      
    end
        
  end
end