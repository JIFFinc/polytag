# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'polytag/version'

Gem::Specification.new do |spec|
  spec.name          = "polytag"
  spec.version       = Polytag::VERSION
  spec.authors       = ["Kelly Becker"]
  spec.email         = ["kellylsbkr@gmail.com"]
  spec.description   = %q{Provides really easy tagging for rails and ActiveRecord models}
  spec.summary       = %q{Provides really easy tagging for rails and ActiveRecord models}
  spec.homepage      = "http://github.com/JIFFinc/polytag"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "awesome_print"
  spec.add_dependency "activerecord", ">= 3.2.13"
  spec.add_dependency "activesupport", ">= 3.2.13"
end
