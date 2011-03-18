module Cuttlebone
  class Definition

    module DSL
      def context object, options={}, &definition
        Cuttlebone.definitions << Definition.new(object, options, &definition)
      end
    end

    class Parser
      def initialize definition
        @definition = definition
      end

      def command string_or_regexp, &block
        @definition.commands << [ string_or_regexp, block, @last_description ]
        @last_description = nil
        self
      end

      def description text
        @last_description = text
        self
      end

      def prompt text='', &block
        @definition.prompt = block_given? ? block : proc { text }
      end
    end

    attr_accessor :prompt, :commands

    def initialize object_or_class, options={}, &definition
      raise ArgumentError, 'missing block' unless block_given?
      @object_or_class = object_or_class
      @options         = options
      @commands        = [] #Array.new(proc { |c| [:self, c, '', nil] })
      @prompt          = proc { |c| '' }

      @parser = Parser.new(self)
      @parser.instance_eval(&definition)
    end

    delegate :command, :to => '@parser'

    def match object
      @object_or_class === object
      # TODO :if :unless options
    end

    def proc_for command
      string_or_regexp, block, description = commands.find { |(sr,b,d)| sr === command } || raise(UnknownCommandError, "Unknown command: #{command.inspect}!")
      return([ block, $~.captures ]) if $~
      return([ block, [] ])
    end
  end

end
