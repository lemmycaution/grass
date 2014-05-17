$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'grass'
require 'dalli'
require 'minitest/autorun'
require 'minitest/pride'
require 'i18n'
require 'em-synchrony/em-http'
require 'goliath/test_helper'

I18n.enforce_available_locales = false

require 'active_record'
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ":memory:")

require "#{Grass.gem_root}/db/migrate/1_create_grass_sources"
ActiveRecord::Schema.define do
  CreateGrassSources.new.change
end

cache_conf = {
  "compress" =>     true,
  "threadsafe" =>   true,
  "namespace" =>    "grass:test",
  "servers" =>      "localhost:11211",
  "async" =>        true
}
Grass.cache = Dalli::Client.new cache_conf.delete("servers").split(","), cache_conf

class MiniTest::Spec
  include Goliath::TestHelper
  def teardown
    Grass.cache.flush
  end
  def setup
    Grass.root = File.expand_path('../../test/dummy', __FILE__)
  end
end