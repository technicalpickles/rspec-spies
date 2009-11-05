require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Spec
  module Matchers
    describe "[object.should] have_received(method, *args)" do
      before do
        @object = String.new
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

    end

  end
end
