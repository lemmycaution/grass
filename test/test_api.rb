require 'minitest_helper'
require 'goliath'

Grass.root = File.expand_path('../../test/dummy', __FILE__)

require 'grass/endpoints/api'

module Grass
  describe :"grass/endpoints/api" do
  
    before do 
      I18n.default_locale = :en
      I18n.available_locales = [:en,:es]
      @layout = Source.create!(key: "/views/layouts/pages/apihome", raw: "HEADER <%= yield %> FOOTER")      
      @layout.commit!
      @page = Source.create!(key: "/pages/apihome", raw: "PAGE CONTENT")            
      @page.commit!
    end
    
    after do
      @layout.destroy!
      @page.destroy!      
    end
   
    let(:api_options) { {:verbose => true, :log_stdout => true, :config => "#{Grass.gem_root}/test/support/grass.rb" } }
  
    it 'returns file json rep' do
      with_api(API, api_options) do
        get_request(:path => '/en/pages/apihome') do |c|
          file = JSON.load(c.response)     
          assert_equal file['keyid'], @page.keyid          
          assert_equal file['raw'], @page.raw          
        end
      end
    end
  
    it 'creates file' do
      with_api(API, api_options) do
        post_request(:path => '/en/texts/testapi', :body => {"raw" => "simple text"}) do |c|
          file = JSON.load(c.response)
          assert_equal file['raw'], "simple text"
        end
      end
    end
  
    it 'updates file' do
      with_api(API, api_options) do
        put_request(:path => '/en/views/layouts/pages/apihome', :body => {"raw" => "HEADER UPDATED <%= yield %> FOOTER"}) do |c|
          file = JSON.load(c.response)
          assert_equal file['keyid'], @layout.keyid
          assert_equal file['raw'], @layout.reload.raw
        end
      end
    end
  
    it 'commit file' do
      with_api(API, api_options) do
        put_request(:path => '/en/views/layouts/pages/apihome', :body => {"raw" => "HEADER UPDATED PUB <%= yield %> FOOTER", "commit" => true}) do |c|
          file = JSON.load(c.response)    
          assert_equal file['raw'], "HEADER UPDATED PUB <%= yield %> FOOTER"       
        end
      end
    end  
  
    it 'deletes file' do
      with_api(API, api_options) do
        delete_request(:path => '/en/pages/apihome') do |c|
          assert_equal JSON.load(c.response), true
        end
      end
    end 
  
  end
end