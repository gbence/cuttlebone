class Cuttlebone::Drivers::Base
  def initialize *stack_objects
    Cuttlebone::Session.set_default *stack_objects
  end

  def sessions
    Cuttlebone::Session.sessions
  end

  def run
    raise NotImplementedError, "You must implement #run in your #{send(:class).name}!"
  end
end
