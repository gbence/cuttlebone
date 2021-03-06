$: << File.expand_path('../', __FILE__)

require File.expand_path('../../vendor/active_support.rb', __FILE__)

module Cuttlebone
  require               'cuttlebone/exceptions'
  autoload :Controller, 'cuttlebone/controller'
  autoload :Definition, 'cuttlebone/definition'
  autoload :Session,    'cuttlebone/session'

  module Drivers
    autoload :Base,  'cuttlebone/drivers/base'
    autoload :Shell, 'cuttlebone/drivers/shell'
    autoload :Rack,  'cuttlebone/drivers/rack'
    autoload :XMPP,  'cuttlebone/drivers/xmpp'
  end

  @@definitions = []
  def self.definitions; @@definitions; end

  def self.run stack_objects, default_driver=Drivers::Shell
    default_driver.new(stack_objects).run
  end
end

include Cuttlebone::Definition::DSL
