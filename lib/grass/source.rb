require 'active_record'
require 'grass/key'
require 'grass/file_sync'
require 'grass/render'
require 'grass/cache'
require 'mime/types'

module Grass
  
  
  ##
  # Source is smallest data object
  
  class Source < ActiveRecord::Base
    
    MIMES = {
      'text'          => 'text/plain',
      'view'          => 'text/html',
      'layout'        => 'text/html',
      'page'          => 'text/html',
      'script'        => 'application/javascript',
      'stylesheet'    => 'text/css'
    }
    
    cattr_accessor :fallback
    
    self.fallback = true
    self.primary_key = :keyid
    self.table_name = :grass_sources
    
    attr_accessor :key
    
    after_initialize :convert_key        
   
    def self.[](*keys)
      keys.flatten.map{|key| 

        key = Key.new(id: key.dup)

        file = self.find_by(locale: key.locale, dir: key.dir, path: key.path)
        if file.nil? && self.fallback
           file = self.find_by(locale: I18n.default_locale, dir: key.dir, path: key.path) 
        end
        file
        
      }.compact
    end
    
    scope :locale,    -> (locale) { unscoped.where(locale: locale.to_s) }
    default_scope     -> { where(hidden: false) }
    
    include FileSync
    include Render
    include Cache    
    
    attr_reader :data
    
    serialize :pairs, Array    
    
    after_initialize :set_mime_type
    before_save :set_mime_type 
    
    def read
      self.binary || self.result || self.raw
    end
    
    def write value
      # self.file.write(value)
      self.update(raw: value)      
    end
    
    def type
      @type ||= self.key.dir.split("/").last.singularize
    end
    
    def hide!
      self.update!(hidden: true)
    end
    
    def show!
      self.update!(hidden: false)
    end  
    
    private
    
    def set_mime_type
      self.mime_type ||=  MIMES[self.type] || MIME::Types.type_for(self.binary.nil? ? self.format : self.filepath).first.to_s
    end
    
    def convert_key
      if self.key.nil?
        self.key = self.filepath ? Key.new(filepath: self.filepath) : Key.new(id: self.keyid)
      elsif self.key.is_a? String
        self.key = Key.new(id: self.key)  
      end
      
      Key::ATTR_TYPES.each do |attr|
        unless attr == :id
          write_attribute(attr,self.key.public_send(attr))
        end
      end
      self.keyid = self.key.id
    end
    
  end
  
end