$LOAD_PATH.unshift File.expand_path('../', __FILE__)

$stdout.sync = true

require 'goliath'
require 'grass'
require "grass/endpoints/#{ARGV.shift}"