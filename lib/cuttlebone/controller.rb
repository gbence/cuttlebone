#
# NOTE: we don't really want to pollute this proxy with a lot of private
# (internal) methods to leave space for <<context>>'s real methods.
class Cuttlebone::Controller

  attr_reader :session, :context, :definition

  def initialize session, context
    @session    = session
    @context    = context
    @definition = Cuttlebone.definitions.find { |d| d.match(context) }
    raise Cuttlebone::InvalidContextError, context, "No definiton was found for #{context.inspect}!" unless @definition
  end

  ##
  # Processes a command on its context's domain.
  #
  def process command
    @next_action = nil
    @output = []

    return([:self, self, [], nil]) if command.empty?
    block, arguments = definition.proc_for(command)

    instance_exec(*arguments, &block)
    action, context = @next_action || [ :self, self ]

    return([ action, context, @output, nil ])
  rescue Cuttlebone::DoubleActionError
    raise
  rescue => e
    return([ :self, self, [], %{Cuttlebone::Controller: #{e.message} (#{e.class})} ])
  end

  def prompt
    return(instance_exec(&@definition.prompt) || '')
  rescue => e
    %{error: #{e.message} (#{e.class.name})}
  end

  def drop
    __save_next_action! :drop
  end

  def add context
    __save_next_action! :add, context
  end

  def replace context
    __save_next_action! :replace, context
  end

  def output *texts
    @output += texts.map(&:to_s)
  end

  def method_missing method_name, *args, &block
    return(@context.send(method_name, *args, &block)) if @context.respond_to?(method_name)
    return(super)
  end

  private

  def __save_next_action! action, context=nil
    raise Cuttlebone::DoubleActionError if @next_action
    @next_action = [ action, context ]
  end

end
