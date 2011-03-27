# encoding: utf-8

require 'spec_helper'
require 'rack/test'

describe Cuttlebone::Drivers::Rack::Middleware do

  include Rack::Test::Methods

  let(:id1) { Digest::SHA1.hexdigest((Time.now.usec*rand).to_s) }
  let(:driver) { Cuttlebone::Drivers::Rack.new }

  let(:null_app) { proc { |env| Rack::Response.new('null').finish } }

  let(:app) { described_class.new(null_app, driver) }

  it "takes a backend and returns a middleware component" do
    subject = described_class.new(null_app)
    subject.should respond_to(:call)
  end

  it "takes an optional Cuttlebone driver as second argument" do
    subject = described_class.new(null_app, driver)
    subject.should respond_to(:call)
  end

  it "raises error when no application was given" do
    expect{ described_class.new() }.should raise_error
  end

  it "handles POST '/init' and returns a unique session identifier" do
    post '/init'
    last_response.should be_ok
    last_response.body.should match(/"id":"[0-9a-f]{40}"/)
  end

  it "handles POST '/prompt' and returns active context's prompt" do
    driver.sessions.should_receive(:[]).with(id1).and_return(mock("Cuttlebone::Session", :id => id1, :prompt => 'prompt'))
    post "/prompt/#{id1}"
    last_response.should be_ok
    last_response.body.should match(/"prompt":"prompt"/)
  end

  it "handles POST '/command' and returns active context's current result" do
    driver.sessions.should_receive(:[]).with(id1).and_return(mock("Cuttlebone::Session", :id => id1, :prompt => 'prompt', :call => [nil,nil,['ok'],nil]))
    post "/call/#{id1}", 'command' => 'x'
    last_response.should be_ok
    last_response.body.should match(/"output":\["ok"\]/)
  end

  it "handles POST '/command' and returns error when no real command was given" do
    driver.sessions.should_receive(:[]).with(id1).and_return(mock("Cuttlebone::Session", :id => id1, :prompt => 'prompt'))
    post "/call/#{id1}"
    last_response.status.should == 409
  end

  xit "handles utf-8 strings properly" do
    s = mock("Cuttlebone::Session", :id => id1, :prompt => 'prompt')
    s.stub!(:call).and_return { |c| [nil, nil, c.reverse, nil] }
    driver.sessions.should_receive(:[]).with(id1).and_return(s)

    post "/call/#{id1}", 'command' => 'árvíztűrő tükörfúrógép'

    last_response.should be_ok
    last_response.body.should match(/"output":"pégórúfröküt őrűtzívrá"/u)
  end

end
