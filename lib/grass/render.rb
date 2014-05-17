require 'grass/render/text'
require 'grass/render/view'
require 'grass/render/layout'
require 'grass/render/page'
require 'grass/render/stylesheet'
require 'grass/render/script'

module Grass
  
  module Render
    
    def render data = {}
      @data = data
      result = "grass/render/#{self.type}".classify.constantize.new(self,@data).render
      commit! result if self.type == "page"
      result
    end
    
    def commit! result = nil
      self.result = result || (self.type =~ /script|stylesheet/ ? self.render : self.raw)
      self.save!
      self
    end
    
  end
  
end