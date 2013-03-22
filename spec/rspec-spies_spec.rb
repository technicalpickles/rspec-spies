require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Spec
  module Matchers
    describe "[object.should] have_received(method, *args)" do
      before do
        @object = String.new("HI!")
      end

      it "matches if method is called with correct args" do
        @object.stub!(:slice)
        @object.slice(5)

        have_received(:slice).with(5).matches?(@object).should be_true
      end

      it "matches if doesn't specify args, even if method is called with args" do
        @object.stub!(:slice)
        @object.slice(5)

        have_received(:slice).matches?(@object).should be_true
      end

      it "matches if specifies nil arg, if method is called with a nil arg" do
        @object.stub!(:slice)
        @object.slice(nil)

        have_received(:slice).with(nil).matches?(@object).should be_true
        have_received(:slice).matches?(@object).should be_true
      end

      it "matches if specifies hash_including, if method is called with has including arguments" do
        @object.stub!(:slice)
        @object.slice({ :foo => :bar, :baz => :quux })

        have_received(:slice).with(hash_including({ :foo => :bar })).matches?(@object).should be_true
        have_received(:slice).with(hash_including({ :foo => :baz })).matches?(@object).should be_false
      end

      it "matches if specifies exactly(x).times" do
        @object.stub!(:slice)
        @object.slice(5)
        @object.slice(5)

        have_received(:slice).exactly(1).times.matches?(@object).should be_false
        have_received(:slice).exactly(2).times.matches?(@object).should be_true
        have_received(:slice).exactly(3).times.matches?(@object).should be_false
      end

      it "matches if called multiple times with different arguments" do
        @object.stub!(:slice)
        @object.slice(1)
        @object.slice(2)

        have_received(:slice).with(1).matches?(@object).should be_true
        have_received(:slice).with(2).matches?(@object).should be_true
        have_received(:slice).with(3).matches?(@object).should be_false
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

      it "doesn't show nil for arguments in description" do
        @object.stub!(:slice)

        @object.slice(3)
        matcher = have_received(:slice).with(3)
        messages = matcher.instance_variable_get("@messages")
        message = messages[:description].call(@object)
        message.should_not include "nil"
      end

      it "correctly lists expects arguments for should_not" do
        @object.stub!(:slice)

        matcher  = have_received(:slice).with(1, 2)
        messages = matcher.instance_variable_get("@messages")
        message  = messages[:failure_message_for_should_not].call(@object)
        message.should == "expected \"HI!\" to not have received :slice with [1, 2], but did"
      end
    end

    describe 'clearing out received messages' do
      class Foo; end

      before do
        Foo.stub(:party)
      end

      it 'base case' do
        Foo.party
        have_received(:party).matches?(Foo).should be_true
      end

      it 'does not match even if the class method has been called in another spec' do
        have_received(:party).matches?(Foo).should be_false
      end
    end
  end
end
