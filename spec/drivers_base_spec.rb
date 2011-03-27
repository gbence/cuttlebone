require 'spec_helper'

describe Cuttlebone::Drivers::Base do
  context ".run() given no stack_objects" do
    it "should call for a new session using default_stack_objects"
  end
end
