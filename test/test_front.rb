require 'minitest_helper'
require 'goliath'
require 'grass/endpoints/front'

module Grass
  describe :"grass/endpoints/front" do
  
    before do
      I18n.available_locales = [:en,:es]
      Source.fallback = true
      @layout = Source.create!(key: "/views/layouts/pages/frontpage", raw: "HEADER <%= yield %> FOOTER")      
      @view = Source.create!(key: "/views/pages/frontpage", raw: "<%= render_content %>")      
      @page = Source.create!(key: "/pages/frontpage", raw: "PAGE CONTENT")            
      @page2 = Source.create!(key: "/es/pages/frontpage", raw: "PAGE CONTENT ES")                
    end
  
    after do
      @page2.destroy
      @page.destroy
      @layout.destroy
      @view.destroy
    end  
   
    let(:api_options) { {:verbose => true, :log_stdout => true, :config => "#{Grass.gem_root}/test/support/grass.rb" } }
  
    # it 'renders any object based on path' do
#       with_api(Front, api_options) do
#         get_request(:path => '/pages/frontpage') do |c|
#           assert_equal c.response, "HEADER PAGE CONTENT FOOTER"
#         end
#       end
#     end
#   
#     it 'renders index default' do
#       with_api(Front, api_options) do
#         get_request(:path => '/frontpage') do |c|
#           assert_equal c.response, "HEADER PAGE CONTENT FOOTER"
#         end
#       end
#     end
  
    it 'renders localised pages' do
      with_api(Front, api_options) do
        get_request(:path => '/es/frontpage') do |c|
          assert_equal c.response, "HEADER PAGE CONTENT ES FOOTER"
        end
      end
    end
  
  
  end
end