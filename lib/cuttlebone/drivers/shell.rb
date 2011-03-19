# TODO FIXME load readline iff it was invoked through command line interface
require 'readline'

class Cuttlebone::Drivers::Shell < Cuttlebone::Drivers::Base
  def run
    loop do
      break if @session.terminated?
      command = Readline::readline("#{@session.prompt} > ")
      break unless command
      Readline::HISTORY.push(command)
      _, _, output, error = @session.call(command)
      print (output<<'').join("\n")
      print "\033[01;31m#{error}\033[00m\n" if error
    end
  end
end

