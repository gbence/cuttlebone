require 'spec_helper'

describe Cuttlebone do
  before :each do
    Cuttlebone.definitions.clear
  end

  it "should start with no contexts defined" do
    Cuttlebone.definitions.should be_empty
  end

  it "should be able to evaluate new context definitions" do
    Cuttlebone.should respond_to(:context)
  end

  it "should start a new session" do
    Cuttlebone.should respond_to(:run)
  end
end
