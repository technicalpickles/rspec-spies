require 'spec/mocks/proxy'
Spec::Mocks::Proxy.class_eval do
  # override defining stubs to record the message was called.
  # there's only one line difference from upstream rspec, but can't change it without fully overriding

  def define_expected_method(sym)
    unless @proxied_methods.include?(sym)
      visibility_string = "#{visibility(sym)} :#{sym}"
      if target_responds_to?(sym)
        munged_sym = munge(sym)
        target_metaclass.instance_eval do
          alias_method munged_sym, sym if method_defined?(sym)
        end
        @proxied_methods << sym
      end
      target_metaclass.class_eval(<<-EOF, __FILE__, __LINE__)
            def #{sym}(*args, &block)
              __mock_proxy.record_message_received(:#{sym}, args, block) # this is the only line changed by rspec-spies in this method
              __mock_proxy.message_received :#{sym}, *args, &block
            end
      #{visibility_string}
      EOF
    end
  end
end

require 'spec/matchers'
Spec::Matchers.module_eval do
  def have_received(sym, &block)
    Spec::Matchers::Matcher.new :have_received, sym, @args, block do |sym, args, block|
      match do |actual|
        actual.received_message?(sym, *@args, &block)
      end

      failure_message_for_should do |actual|
        "expected #{actual.inspect} to have received #{sym.inspect} with #{args.inspect}"
      end

      failure_message_for_should_not do |actual|
        "expected #{actual.inspect} to not have received #{sym.inspect} with #{args.inspect}, but did"
      end

      description do
        "to have received #{sym.inspect} with #{args.inspect}"
      end

      def with(*args)
        @args = args
        self
      end
    end
  end
end
