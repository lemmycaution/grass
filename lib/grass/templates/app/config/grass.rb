require 'i18n'
require 'grass'
require "ip_country"
require 'erb'
require 'active_record'
require 'yaml'

I18n.enforce_available_locales = false
I18n.default_locale = ENV['DEFAULT_LOCALE'] ? ENV['DEFAULT_LOCALE'].to_sym : :en
I18n.available_locales = ENV['AVAILABLE_LOCALES'] ? ENV['AVAILABLE_LOCALES'].split(",").map(&:to_sym) : [:en]

db_conf = YAML.load(ERB.new(File.read('config/database.yml')).result)[Grass.env]
ActiveRecord::Base.establish_connection db_conf

Time.zone = ENV['TIME_ZONE'] || "London"

ENV['GEOIP_FILE'] ||= "#{Grass.app_root}/db/geo_ip.dat"
if ::File.exists?(ENV['GEOIP_FILE'])
  IPCountry.init ENV['GEOIP_FILE'] 
  config['ip_country'] = IPCountry
end

config['dalli'] = Grass.cache