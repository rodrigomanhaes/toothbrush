$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'toothbrush'
require 'capybara'
require 'capybara/dsl'

require File.join(File.dirname(__FILE__), 'dummy_app', 'app')
Capybara.app = Sinatra::Application

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.include Capybara::DSL
end
