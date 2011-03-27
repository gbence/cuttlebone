require 'rack'
require 'haml'
require 'sass/plugin/rack'
require 'json'

class Cuttlebone::Drivers::Rack < Cuttlebone::Drivers::Base

  ##
  #
  # Cuttlebone::Drivers::Rack::Middleware
  #
  # It responds only to predefined HTTP POST calls and deals them according to
  # Cuttlebone definitions and the associated driver's internal state.
  #
  class Middleware

    def initialize app, driver=nil
      @app    = app
      @driver = driver || Cuttlebone::Drivers::Rack.new
    end

    def call env
      @request  = Rack::Request.new(env)

      return(@app.call(env)) unless @request.post?
      return(@app.call(env)) unless @request.path =~ %r{^/(?:(?:prompt|call)/([0-9a-f]{40}))|init$}
      # return(@app.call(env)) unless @request.is_json_request?

      @response = Rack::Response.new
      @response['Content-Type'] = 'application/json'

      if @request.path == '/init'
        session = @driver.sessions.create
        json 'id' => session.id, 'prompt' => session.prompt
      elsif @request.path =~ %r{/prompt/([0-9a-f]{40})}
        id      = $1
        session = @driver.sessions[id]
        json 'id' => session.id, 'prompt' => session.prompt
      elsif @request.path =~ %r{/call/([0-9a-f]{40})}
        id      = $1
        session = @driver.sessions[id]

        if command=@request.params['command']
          _, _, output, error = session.call(command.force_encoding("UTF-8"))
          json 'id' => session.id, 'prompt' => session.prompt, 'output' => output, 'error' => error
        else
          @response.status = 409
          json 'id' => session.id, 'prompt' => session.prompt, 'error' => 'No command was given!'
        end
      end

      return(@response.finish)
    rescue
      json 'id' => (session.id rescue nil), 'prompt' => (session.prompt rescue nil), 'error' => $!.message
      return(@response.finish)
    end

    private

    def json data
      @response.write(data.to_json)
    end
  end

  ##
  #
  # Cuttlebone::Driver::Rack::Application
  #
  # It's a fully functional rack-enabled application that serves all other
  # materials for a fully functional Cuttlebone web server.
  #
  class Application

    STATIC_FILES = %w{ /index.html /favicon.png /stylesheets/cuttlebone.css /javascripts/cuttlebone.js /javascripts/jquery.min.js }

    def self.public_path path=''
      File.expand_path("../../../../public/#{path}", __FILE__)
    end

    def call(env)
      @request  = Rack::Request.new(env)
      @response = Rack::Response.new

      if @request.get? and @request.path == '/'
        redirect_to '/index.html'
      elsif @request.get? and STATIC_FILES.include?(@request.path)
        static @request.path
      else
        error 'Not found.', 404
      end

      @response.finish
    end

    private

    def static path
      @response.write(File.read(File.expand_path("../../../../public#{path}", __FILE__)))
    end

    def error message, status=500
      @response.write(File.read(File.expand_path("../../../../public/error.html", __FILE__)).gsub(/Error happens.  It always does./, message))
      @response.status = status
    end

    def redirect_to path
      @response.redirect(path)
    end
  end

  ##
  #
  # Starts Cuttlebone Rack application.
  #
  def run
    trap(:INT) do
      if server.respond_to?(:shutdown)
        server.shutdown
      else
        exit
      end
    end
    server.run app, :Host=>'0.0.0.0', :Port=>9292
  end

  private

  ##
  #
  # Builds Rack application stack.
  #
  # @return Rack::Application
  #
  def app
    driver = self
    Rack::Builder.app do
      use Rack::ShowExceptions
      use Rack::Lint
      use Rack::ContentType
      use Rack::ContentLength
      use Rack::Session::Pool, :expire_after => 2592000
      use Middleware, driver
      run Application.new
    end
  end

  ##
  #
  # Returns a Rack server.
  #
  def server
    @server ||= ::Rack::Handler.default()
  end
end
