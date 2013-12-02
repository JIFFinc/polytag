begin
  require 'awesome_print'
  Pry.config.print = proc { |output, value| output.puts value.ai }
rescue LoadError => err
  puts "no awesome_print :("
end

GEM_DIR  = File.dirname(__FILE__)
SPEC_DIR = File.join(GEM_DIR, 'spec')

# Load dependencies
require 'rspec/rails/extensions/active_record/base'
require 'active_support'
require 'active_record'

# Load in the support for AR
require "#{SPEC_DIR}/support/active_record"

# Load in the gem we are testing
require 'polytag'

# The test models
require "#{SPEC_DIR}/support/owner"
require "#{SPEC_DIR}/support/taggable"
