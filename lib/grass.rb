require "grass/version"
require "grass/core_ext/kernel"
require 'pathname'
require 'dalli'
require 'erb'
require 'yaml'
require 'active_support/core_ext/hash'

module Grass
  
  class << self
    
    def gem_root
      @@gemroot ||= File.expand_path('../..', __FILE__)
    end
  
    def root
      @@root ||= find_root_with_flag("Procfile", Dir.pwd).to_s
    end

    def root= root
      @@root = root
    end
  
    def app_root
      @@app_root ||= "#{self.root}/app".gsub("//","/")
    end
  
    def cache
      $cache ||= begin
        config = self.load_config('cache')
        Dalli::Client.new config.delete("servers").split(","), config.symbolize_keys!
      end
    end
  
    def cache=cache
      $cache = cache
    end
  
    def env
      ENV['RACK_ENV'] ||= "development"
    end
  
    def load_config file
      db_conf = YAML.load(ERB.new(File.read("#{Grass.root}/config/#{file}.yml")).result)[self.env]
    end
  
  end
  
  private

  # i steal this from rails
  def self.find_root_with_flag(flag, default=nil)
    root_path = self.class.called_from[0]

    while root_path && ::File.directory?(root_path) && !::File.exist?("#{root_path}/#{flag}")
      parent = ::File.dirname(root_path)
      root_path = parent != root_path && parent
    end

    root = ::File.exist?("#{root_path}/#{flag}") ? root_path : default
    raise "Could not find root path for #{self}" unless root

    RbConfig::CONFIG['host_os'] =~ /mswin|mingw/ ?
    Pathname.new(root).expand_path : Pathname.new(root).realpath
  end
  
end
