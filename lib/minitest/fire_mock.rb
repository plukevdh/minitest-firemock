require 'minitest/mock'

class MiniTest::FireMock < MiniTest::Mock
  def initialize(constant)
    @constant_name = constant
    @constant = constantize(constant)

    super()
  end

  def expect(name, retval, args = [])
    method = @constant.instance_method(name) rescue nil

    if @constant and not method
      raise MockExpectationError, "expected #{@constant_name} to define `#{name}`, but it doesn't"
    end

    if method
      if variable_arity?(method) and args.size > method.arity.abs
        raise MockExpectationError, "`#{name}` expects 0..#{method.arity.abs} arguments, given #{args.size}"
      elsif !variable_arity?(method) and method.arity != args.size
        raise MockExpectationError, "`#{name}` expects #{method.arity} arguments, given #{args.size}"
      end
    end

    super(name, retval, args)
  end

  private
  # Borrowed from ActiveSupport.
  def variable_arity?(method)
    method.arity < 0
  end

  def constantize(camel_cased_word)
    names = camel_cased_word.split('::')
    names.shift if names.empty? || names.first.empty?

    constant = Object
    names.each do |name|
      constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
    end
    constant
  rescue NameError
    nil
  end
end
