require 'rspec/mocks/method_double'
RSpec::Mocks::MethodDouble.class_eval do
  # override defining stubs to record the message was called.
  # there's only one line difference from upstream rspec, but can't change it without fully overriding
  def define_proxy_method
    method_name = @method_name
    visibility_for_method = "#{visibility} :#{method_name}"
    object_singleton_class.class_eval(<<-EOF, __FILE__, __LINE__)
       def #{method_name}(*args, &block)
         __mock_proxy.record_message_received :#{method_name}, *args, &block
         __mock_proxy.message_received :#{method_name}, *args, &block
       end
    #{visibility_for_method}
    EOF
  end
end

require 'rspec/matchers'
RSpec::Matchers.define :have_received do |sym, args, block|
  match do |actual|
    actual.received_message?(sym, *@args, &block)
  end


  failure_message_for_should do |actual|
    "expected #{actual.inspect} to have received #{sym.inspect} with #{@args.inspect}"
  end


  failure_message_for_should_not do |actual|
    "expected #{actual.inspect} to not have received #{sym.inspect} with #{@args.inspect}, but did"
  end


  description do
    "to have received #{sym.inspect} with #{@args.inspect}"
  end


  def with(*args)
    @args = args
    self
  end
end
