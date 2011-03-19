# TODO FIXME
class Cuttlebone::Drivers::Test < Cuttlebone::Drivers::Base
  def initialize *args
    super
    stack = []
    @session.stack.each { |c| stack << c }
    @stack_history = [ stack ]
  end

  def call command
    a, n, o, e = @session.call(command)
    stack = []
    @session.stack.each { |c| stack << c }
    @stack_history << stack
    @output = o
    @error  = e
    [ a, n, o, e ]
  end

  attr_reader :output, :error

  def active_context
    @stack_history[-1].last
  end

  def previous_active_context
    @stack_history[-2].last
  end

  delegate :terminated?, :prompt, :internal_error, :to => '@session'

end
