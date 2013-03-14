require 'rspec/mocks/proxy'

RSpec::Mocks::Proxy.class_eval do
  alias_method :oldsp_message_received, :message_received
  alias_method :oldsp_reset, :reset

  def message_received(message, *args, &block)
    record_message_received(message, *args, &block)
    oldsp_message_received(message, *args, &block)
  end

  def reset
    @messages_received = []
    oldsp_reset
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
    messages_received = actual.send(:__mock_proxy).instance_variable_get("@messages_received")
    messages_received.any? do |message|
      received_method_name, received_args, received_block = *message
      result = (received_method_name == method_name)
      result &&= argument_expectation_class.new(@args || any_args).args_match?(received_args)
      result &&= (received_block == block)
    end
  end

  chain :with do |*args|
    @args = args
  end

  failure_message_for_should do |actual|
    "expected #{actual.inspect} to have received #{method_name.inspect}#{args_message}"
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
end
