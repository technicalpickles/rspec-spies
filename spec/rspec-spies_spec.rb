require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Spec
  module Matchers
    describe "[object.should] have_received(method, *args)" do
      before do
        @object = String.new("HI!")
      end

      it "does match if method is called with correct args" do
        @object.stub!(:slice)
        @object.slice(5)

        have_received(:slice).with(5).matches?(@object).should be_true
      end

      it "does not match if method is called with incorrect args" do
        @object.stub!(:slice)
        @object.slice(3)

        have_received(:slice).with(5).matches?(@object).should be_false
      end

      it "does not match if method is not called" do
        @object.stub!(:slice)

        have_received(:slice).with(5).matches?(@object).should be_false
      end

      it "correctly lists expects arguments for should" do
        @object.stub!(:slice)

        matcher  = have_received(:slice).with(5, 3)
        messages = matcher.instance_variable_get("@messages")
        message  = messages[:failure_message_for_should].call(@object)
        message.should == "expected \"HI!\" to have received :slice with [5, 3]"
      end

      it "correctly lists expects arguments for should_not" do
        @object.stub!(:slice)

        matcher  = have_received(:slice).with(1, 2)
        messages = matcher.instance_variable_get("@messages")
        message  = messages[:failure_message_for_should_not].call(@object)
        message.should == "expected \"HI!\" to not have received :slice with [1, 2], but did"
      end
    end

  end
end
