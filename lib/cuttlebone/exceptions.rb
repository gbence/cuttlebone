module Cuttlebone

  ##
  # Raised when Controller is invoked with an invalid (not matching) context.
  # 
  class InvalidContextError < StandardError
    attr_reader :context
    def initialize context, *args, &block
      @context = context
      super *args, &block
    end
  end

  ##
  # Raised on unknown command calls.
  #
  class UnknownCommandError < StandardError; end

  ##
  # Raised when multiple actions are invoked simultanously.
  #
  class DoubleActionError < StandardError; end

end
