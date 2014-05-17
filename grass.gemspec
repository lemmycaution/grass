# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'grass/version'

Gem::Specification.new do |spec|
  spec.name          = "grass"
  spec.version       = Grass::VERSION
  spec.authors       = ["Onur Uyar"]
  spec.email         = ["me@onuruyar.com"]
  spec.summary       = %q{Yet another ruby framework}
  spec.homepage      = "http://github.com/lemmycaution/grass"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency 'em-http-request'    

  spec.add_dependency "pg"  
  spec.add_dependency "i18n"    
  spec.add_dependency "activerecord"

  spec.add_dependency "tilt"    
  spec.add_dependency "sass"  
  spec.add_dependency "coffee-script"  
  spec.add_dependency "yui-compressor" 
  spec.add_dependency "uglifier" 
  spec.add_dependency "redcarpet"  
  spec.add_dependency "mime-types"  
  
  spec.add_dependency 'goliath'
  spec.add_dependency "ip_country"      
  spec.add_dependency "dalli"

  spec.add_dependency "commander"
end
