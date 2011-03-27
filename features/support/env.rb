require File.expand_path('../../../lib/cuttlebone.rb', __FILE__)
require 'cucumber/formatter/unicode'

require 'capybara/cucumber'
require 'capybara/session'
Capybara.default_selector = :css
Capybara.default_driver = :selenium
#Capybara.app = 0 # 

