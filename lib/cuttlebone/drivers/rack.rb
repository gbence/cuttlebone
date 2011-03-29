require 'rack'
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
      request = Rack::Request.new(env)

      return(@app.call(env)) unless request.post?
      return(@app.call(env)) unless request.path =~ %r{^/(?:(?:prompt|call)/([0-9a-f]{40}))|init$}
      # return(@app.call(env)) unless @request.is_json_request?

      response = Rack::Response.new
      response['Content-Type'] = 'application/json'

      results = { 'id' => nil, 'prompt' => nil }

      begin
        session = get_session_for(request.path)
        raise ArgumentError, "Cannot load cuttlebone-session!" unless session

        case request.path
        when '/init', %r{^/prompt/}
          results.merge! 'id' => session.id, 'prompt' => session.prompt
        when %r{^/call/}
          if command=request.params['command']
            _, _, output, error = session.call(command.force_encoding("UTF-8"))
            results.merge! 'id' => session.id, 'prompt' => session.prompt, 'output' => output, 'error' => error
          else
            response.status = 409
            results.merge! 'id' => session.id, 'prompt' => session.prompt, 'error' => 'No command was given!'
          end
        end
      rescue
        results.merge! 'id' => (session.id rescue nil), 'prompt' => (session.prompt rescue nil), 'error' => $!.message
      end

      response.write(results.to_json)

      return(response.finish)
    end

    private

    def get_session_for path
      case path
      when '/init'
        @driver.sessions.create
      when %r{^/(?:prompt|call)/([0-9a-f]{40})$}
        @driver.sessions[$1]
      end
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
      request  = Rack::Request.new(env)
      response = Rack::Response.new

      if request.get? and request.path == '/'
        response.redirect('/index.html')
      elsif request.get? and STATIC_FILES.include?(request.path)
        response['Content-Type'] = 'application/javascript' if request.path =~ /\.js$/
        response['Content-Type'] = 'text/css' if request.path =~ /\.css$/
        response['Content-Type'] = 'image/png' if request.path =~ /\.png$/

        response.write(File.read(File.expand_path("../../../../public#{request.path}", __FILE__)))
        response.status = 200
      else
        response.write(File.read(File.expand_path("../../../../public/error.html", __FILE__)).gsub(/Error happens.  It always does./, 'Not found.'))
        response.status = 404
      end

      response.finish
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
