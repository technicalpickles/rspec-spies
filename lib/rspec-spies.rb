require 'rspec/mocks/method_double'
RSpec::Mocks::MethodDouble.class_eval do
  # override defining stubs to record the message was called.
  # there's only one line difference from upstream rspec, but can't change it without fully overriding
  def define_proxy_method
    return if @method_is_proxied

    object_singleton_class.class_eval <<-EOF, __FILE__, __LINE__ + 1
      def #{@method_name}(*args, &block)
        __mock_proxy.record_message_received :#{@method_name}, *args, &block
        __mock_proxy.message_received :#{@method_name}, *args, &block
      end
      #{visibility_for_method}
    EOF
    @method_is_proxied = true
  end

  def visibility_for_method
    "#{visibility} :#{method_name}"
  end
end

require 'rspec/expectations'
require 'rspec/matchers'

argument_expectation_class = begin
  require 'rspec/mocks/argument_list_matcher'
  RSpec::Mocks::ArgumentListMatcher
rescue LoadError
  require 'rspec/mocks/argument_expectation'
  RSpec::Mocks::ArgumentExpectation
end

RSpec::Matchers.define :have_received do |method_name, args, block|
  match do |actual|
    messages_received = actual.send(:__mock_proxy).instance_variable_get("@messages_received").keep_if do |message|
      received_method_name, received_args, received_block = *message
      result = (received_method_name == method_name)
      result &&= argument_expectation_class.new(@args || any_args).args_match?(received_args)
      result &&= (received_block == block)
    end

    if @times
      messages_received.length == @expected_count
    else
      messages_received.length > 0
    end
  end

  chain :with do |*args|
    @args = args
  end

  chain :exactly do |count|
    @expected_count = count
  end

  chain :times do
    @times = true
  end

  failure_message_for_should do |actual|
    "expected #{actual.inspect} to have received #{method_name.inspect}#{args_message}#{times_message}"
  end

  failure_message_for_should_not do |actual|
    "expected #{actual.inspect} to not have received #{method_name.inspect}#{args_message}, but did"
  end

  description do
    "to have received #{method_name.inspect}#{args_message}"
  end

  def args_message
    @args ? " with #{@args.inspect}" : ""
  end

  def times_message
    @times ? " exactly #{@expected_count} times" : ""
  end
end
