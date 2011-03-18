require 'rspec'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'cuttlebone'))

RSpec.configure do |config|
  config.alias_it_should_behave_like_to(:it_should_behave_like, '')
  config.filter_run :focused => true
  config.run_all_when_everything_filtered = true
end
