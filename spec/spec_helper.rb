$:.unshift File.expand_path("..", __FILE__)
$:.unshift File.expand_path("../../lib", __FILE__)

require "coveralls"
Coveralls.wear!

require "bundler/setup"
require "rspec"

RSpec.configure do |config|
end
