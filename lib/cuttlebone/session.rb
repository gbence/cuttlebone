require 'digest/sha1'

class Cuttlebone::Session
  
  # TODO FIXME locking / mutexes / serialization / deserialization
  class NotFound < StandardError; end

  @@sessions = {}

  @@default_stack_objects = []

  module SessionCollectionExtensions
    def [] key
      raise NotFound unless has_key?(key)
      super(key)
    end

    def create *stack_objects
      s = Cuttlebone::Session.new(*stack_objects)
      send(:[]=, s.id, s)
      s
    end
  end

  @@sessions.extend SessionCollectionExtensions

  def self.set_default *stack_objects
    @@default_stack_objects = stack_objects
  end

  def self.sessions
    @@sessions
  end

  def initialize *stack_objects
    options  = stack_objects.extract_options!
    @id      = options[:id] || Digest::SHA1.hexdigest(Time.now.to_s + Time.now.usec.to_s + rand(1000).to_s) # TODO FIXME
    @@default_stack_objects.each { |so| stack_objects << (so.dup rescue so) } if stack_objects.empty?
    @stack ||= stack_objects.map{ |o| Cuttlebone::Controller.new(self, o) }
  rescue Cuttlebone::InvalidContextError => e
    @internal_error = %{Context initialization failed for #{e.context.inspect}!}
  rescue => e
    @internal_error = %{Internal error occured: #{e.message} (#{e.class})}
  ensure
    @stack ||= []
  end

  attr_reader :id, :stack, :internal_error

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
