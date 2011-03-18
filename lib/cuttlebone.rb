require 'rubygems'
require 'bundler/setup'

require 'active_support/core_ext'

$: << File.expand_path('../', __FILE__)

module Cuttlebone
  require               'cuttlebone/exceptions'
  autoload :Controller, 'cuttlebone/controller'
  autoload :Definition, 'cuttlebone/definition'
  autoload :Session,    'cuttlebone/session'

  @@definitions = []
  mattr_reader :definitions

  def self.run starting_objects, default_driver=Session::Shell
    default_driver.new(starting_objects).run
  end
end

include Cuttlebone::Definition::DSL
