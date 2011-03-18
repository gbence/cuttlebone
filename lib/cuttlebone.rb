$: << File.expand_path('../', __FILE__)

require File.expand_path('../../vendor/active_support.rb', __FILE__)

module Cuttlebone
  require               'cuttlebone/exceptions'
  autoload :Controller, 'cuttlebone/controller'
  autoload :Definition, 'cuttlebone/definition'
  autoload :Session,    'cuttlebone/session'

  @@definitions = []
  def self.definitions; @@definitions; end

  def self.run starting_objects, default_driver=Session::Shell
    default_driver.new(starting_objects).run
  end
end

include Cuttlebone::Definition::DSL
