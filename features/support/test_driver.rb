class Cuttlebone::Session::Test < Cuttlebone::Session::Base
  def initialize *args
    super
    stack = []
    @stack.each { |c| stack << c }
    @stack_history = [ stack ]
  end

  def process command
    stack = []
    @stack.each { |c| stack << c }
    @stack_history << stack
    a, n, o, e = super(command)
    @output = o
    @error  = e
    [ a, n, o, e ]
  end

  attr_reader :output, :error

  def previous_active_context
    @stack_history[-2].last
  end
end
