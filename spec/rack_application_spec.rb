require 'spec_helper'
require 'rack/test'

describe Cuttlebone::Drivers::Rack::Application do

  include Rack::Test::Methods

  let(:app) { described_class.new() }

  it "redirects '/' to '/index.html'" do
    get '/'
    last_response.should be_redirect
    last_response.location.should == '/index.html'
  end

  it "returns 'index.html'" do
    get '/'
    follow_redirect!
    last_response.should be_ok
    last_response.body.should match('x')
  end

  it "returns static files" do # stylesheets, javascripts
    get '/stylesheets/cuttlebone.css'
    last_response.should be_ok
    
    get '/javascripts/cuttlebone.js'
    last_response.should be_ok

    get '/favicon.png'
    last_response.should be_ok

    get '/javascripts/jquery.min.js'
    last_response.should be_ok
  end

  it "returns error on wrong request" do
    get '/something/else'
    last_response.should be_not_found
    last_response.body.should match('Not found.')
  end
end
