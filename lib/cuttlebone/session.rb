class Cuttlebone::Session

  def initialize *stack_objects
    @stack ||= stack_objects.map{ |o| Cuttlebone::Controller.new(self, o) }
  rescue Cuttlebone::InvalidContextError => e
    @internal_error = %{Context initialization failed for #{e.context.inspect}!}
  rescue => e
    @internal_error = %{Internal error occured: #{e.message} (#{e.class})}
  ensure
    @stack ||= []
  end

  attr_reader :stack, :internal_error

  def active_context
    stack.last
  end

  delegate :name, :prompt, :to => :active_context

  def call command
    process command
  end

  def terminated?
    stack.empty?
  end

  private

  def process command
    active_context = stack.pop

    action, next_context, output, error = begin
                                            a, n, o, e = active_context.process(command)
                                            raise ArgumentError, "Unknown action: #{a}" unless [ :self, :replace, :add, :drop ].include?(a.to_s.to_sym)
                                            raise TypeError, "Output must be an instance of String or nil!" unless o.is_a?(Array) or o.nil?
                                            raise TypeError, "Error must be an instance of String or nil!" unless e.is_a?(String) or e.nil?
                                            [ a.to_s.to_sym, n, o, e ]
                                          rescue => e
                                            [ :self, active_context, nil, %{Cuttlebone::Session: #{e.message} (#{e.class})} ]
                                          end
    case action
    when :self
      stack << active_context
    when :replace
      stack << Cuttlebone::Controller.new(self, next_context)
    when :add
      stack << active_context << Cuttlebone::Controller.new(self, next_context)
    when :drop
      # noop
    end
    [ action, next_context, output, error ]
  end

end
