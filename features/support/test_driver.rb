# TODO FIXME
class Cuttlebone::Drivers::Test < Cuttlebone::Drivers::Base
  def initialize *stack_objects
    super
    @session = Cuttlebone::Session.sessions.create(*stack_objects)
    save_stack_to_history
  end

  def call command
    a, n, o, e = @session.call(command)
    save_stack_to_history
    @output = o
    @error  = e
    [ a, n, o, e ]
  end

  attr_reader :output, :error

  def active_context
    @history[-1].last
  end

  def previous_active_context
    @history[-2].last
  end

  delegate :terminated?, :prompt, :internal_error, :to => '@session'

  private

  def save_stack_to_history
    stack = []
    @session.stack.each { |c| stack << c }
    (@history ||= []) << stack
  end

end
