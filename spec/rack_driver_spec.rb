require 'spec_helper'

describe Cuttlebone::Drivers::Rack do

  let(:stack) { [:x] }

  context ".run" do
    let(:rack_driver) { described_class.new(stack) }

    subject { rack_driver.run }

    it "starts an entire application" do
      ::Rack::Handler.should_receive(:default).and_return(mock('Rack::Handler', :run => true))
      ::Rack::Builder.should_receive(:app).and_return(mock('Application', :call => true))
      subject
    end
  end

end
