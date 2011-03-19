class Cuttlebone::Drivers::Base
  def initialize *stack_objects
    @session = Cuttlebone::Session.new(*stack_objects)
  end

  def run
    raise NotImplementedError, "You must implement #run in your #{send(:class).name}!"
  end
end
