# TODO FIXME load readline iff it was invoked through command line interface
require 'readline'
require 'termios'

require File.expand_path('../../../../vendor/terminal', __FILE__)

class Cuttlebone::Session::Shell < Cuttlebone::Session::Base
  def run
    loop do
      break if terminated?
      command = Readline::readline("#{prompt} > ")
      break unless command
      Readline::HISTORY.push(command)
      _, _, output, error = call(command)
      print (output<<'').join("\n")
      print "\033[01;31m#{error}\033[00m\n" if error
    end
  end
end

