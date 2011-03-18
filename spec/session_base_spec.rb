require 'spec_helper'

describe Cuttlebone::Session::Base do
  let(:valid_context) { 'x' }
  let(:valid_command) { 'y' }

  let(:valid_context_definition) do
    x = mock('Definition:x')
    x.stub!(:match).and_return() { |*args| args == [valid_context] }
    x.stub!(:proc_for).with(any_args()).and_return([proc{}, []])
    x
  end

  before :each do
    Cuttlebone.stub!(:definitions).and_return([ valid_context_definition ])
  end

  context "having an active 'x' context" do
    subject { Cuttlebone::Session::Base.new(valid_context) }

    it { should_not be_terminated }

    it "should have no internal error" do
      subject.internal_error.should be_blank
    end

    it "should evaluate a string command" do
      valid_context_definition.should_receive(:match).with(valid_context).and_return(true)
      subject.call(valid_command)
    end

    it "should return active context" do
      subject.should respond_to(:active_context)
      subject.active_context.should be_a(Cuttlebone::Controller)
    end

    it "should return with a [action, context, output, error] quadruple" do
      a, c, o, e = subject.call(valid_context)
      [ :drop, :replace, :self, :add ].should include(a)
      o and o.should be_a(Array)
      e and e.should be_a(String)
    end
  end

  context "having no active contexts" do
    subject { Cuttlebone::Session::Base.new() }

    it "should have no internal error" do
      subject.internal_error.should be_blank
    end

    it { should be_terminated }
  end

  context "having 1 context" do
    subject { Cuttlebone::Session::Base.new(valid_context) }

    it "should have no internal error" do
      subject.internal_error.should be_blank
    end

    it { should_not be_terminated }

    it "should be terminated after a 'drop'" do
      valid_context_definition.should_receive(:proc_for).with('drop').and_return([proc{drop}, []])
      subject.call('drop')
      subject.should be_terminated
    end
  end

  context "given a wrong context" do
    subject { Cuttlebone::Session::Base.new('invalid_context') }

    it "should indicate internal error" do
      subject.internal_error.should_not be_blank
    end

    it "should be terminated" do
      subject.should be_terminated
    end
  end
end
