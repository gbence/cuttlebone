# (active_support)/lib/active_support/core_ext/module/remove_method.rb
class Module
  def remove_possible_method(method)
    remove_method(method)
  rescue NameError
  end

  def redefine_method(method, &block)
    remove_possible_method(method)
    define_method(method, &block)
  end
end

# (active_support)/lib/active_support/core_ext/module/delegation.rb (stripped)
class Module
  def delegate(*methods)
    options = methods.pop
    unless options.is_a?(Hash) && to = options[:to]
      raise ArgumentError, "Delegation needs a target. Supply an options hash with a :to key as the last argument (e.g. delegate :hello, :to => :greeter)."
    end

    if options[:prefix] == true && options[:to].to_s =~ /^[^a-z_]/
      raise ArgumentError, "Can only automatically set the delegation prefix when delegating to a method."
    end

    prefix = options[:prefix] && "#{options[:prefix] == true ? to : options[:prefix]}_" || ''

    file, line = caller.first.split(':', 2)
    line = line.to_i

    methods.each do |method|
      on_nil =
        if options[:allow_nil]
          'return'
        else
          %(raise "#{self}##{prefix}#{method} delegated to #{to}.#{method}, but #{to} is nil: \#{self.inspect}")
        end

      module_eval(<<-EOS, file, line - 5)
        if instance_methods(false).map(&:to_s).include?("#{prefix}#{method}")
          remove_possible_method("#{prefix}#{method}")
        end

        def #{prefix}#{method}(*args, &block)               # def customer_name(*args, &block)
          #{to}.__send__(#{method.inspect}, *args, &block)  #   client.__send__(:name, *args, &block)
        rescue NoMethodError                                # rescue NoMethodError
          if #{to}.nil?                                     #   if client.nil?
            #{on_nil}                                       #     return # depends on :allow_nil
          else                                              #   else
            raise                                           #     raise
          end                                               #   end
        end                                                 # end
      EOS
    end
  end
end

# (active_support)/lib/active_support/core_ext/array/extract_options.rb (stripped)
class Hash
  def extractable_options?
    instance_of?(Hash)
  end
end

class Array
  def extract_options!
    if last.is_a?(Hash) && last.extractable_options?
      pop
    else
      {}
    end
  end
end

