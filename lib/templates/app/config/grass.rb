require 'i18n'
require 'grass'
require 'ip_country'
require 'active_record'

Time.zone = ENV['TIME_ZONE'] || "London"
I18n.load_path << Dir.glob("#{Grass.root}/config/locales/**/*.yml")
I18n.enforce_available_locales = false
I18n.backend.class.send(:include, I18n::Backend::Fallbacks)
I18n.default_locale = ENV['DEFAULT_LOCALE'] ? ENV['DEFAULT_LOCALE'].to_sym : :en
I18n.available_locales = ENV['AVAILABLE_LOCALES'] ? ENV['AVAILABLE_LOCALES'].split(",").map(&:to_sym) : [:en]

ActiveRecord::Base.establish_connection Grass.load_config('database')

if respond_to?(:config)
  
  # config['enable_cache_for_development'] = true

  ENV['GEOIP_FILE'] ||= "#{Grass.root}/db/geo_ip.dat"
  if ::File.exists?(ENV['GEOIP_FILE'])
    IPCountry.init ENV['GEOIP_FILE'] 
    config['ip_country'] = IPCountry
  end

  config['dalli'] = Grass.cache

end