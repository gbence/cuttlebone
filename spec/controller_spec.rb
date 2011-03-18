require 'spec_helper'

describe Cuttlebone::Controller do
  let(:valid_session) { mock("Cuttlebone::Session::Base") }
  let(:valid_context) { 'x' }

  let(:drop_proc)    { proc { |*args| output 'dropped'; drop } }
  let(:self_proc)    { proc { |*args| output 'noop'; self } }
  let(:add_proc)     { proc { |*args| output 'added'; add 'x' } } # TODO FIXME change 'x' => valid_context somehow 'cause they are the same instance
  let(:replace_proc) { proc { |*args| output 'replaced'; replace 'x' } }
  let(:double_action_error_proc) { proc { |*args| output 'double action error'; drop; add 'x' } }
  let(:prompt_proc)  { proc { |*args| 'prompt' } }

  let(:valid_context_definition) do
    x = mock('Cuttlebone::Definition "x"')
    x.stub!(:match).and_return() { |*args| args == [valid_context] }
    x.stub!(:proc_for).with('drop').and_return(drop_proc)
    x.stub!(:proc_for).with('self').and_return(self_proc)
    x.stub!(:proc_for).with('add').and_return(add_proc)
    x.stub!(:proc_for).with('replace').and_return(replace_proc)
    x.stub!(:proc_for).with('double').and_return(double_action_error_proc)
    x.stub!(:prompt).and_return(prompt_proc)
    x
  end

  before :each do
    Cuttlebone.stub!(:definitions).and_return([ valid_context_definition ])
  end

  context "given a valid context" do
    subject { Cuttlebone::Controller.new(valid_session, valid_context) }

    it "should return context object" do
      subject.context.should == valid_context
    end

    it "should return [:self, self, nil, nil] to empty commands" do
      subject.process('').should == [ :self, subject, [], nil ]
    end

    it "should return [:drop, nil, 'dropped', nil] to 'drop' commands" do
      subject.process('drop').should == [:drop, nil, ['dropped'], nil]
    end

    it "should return [:self, self, 'noop', nil] to 'drop' commands" do
      subject.process('self').should == [:self, subject, ['noop'], nil]
    end

    it "should return [:add, valid_context, 'added', nil] to 'drop' commands" do
      subject.process('add').should == [:add, valid_context, ['added'], nil]
    end

    it "should return [:replace, valid_context, 'replaced', nil] to 'drop' commands" do
      subject.process('replace').should == [:replace, valid_context, ['replaced'], nil]
    end

    it "should raise error on double action commands" do
      expect{ subject.process('double') }.should raise_error(Cuttlebone::DoubleActionError)
    end

    it "should execute command in <<context>>'s context" do
      valid_context_definition.stub!(:proc_for).with('x').and_return(proc{ x })
      valid_context.should_receive(:x)
      subject.process('x')
    end

    it "should execute prompt in <<context>>'s context" do
      valid_context_definition.stub!(:prompt).and_return(proc{ x })
      valid_context.should_receive(:x)
      subject.prompt()
    end
  end

  context "given an invalid context" do
    it "should raise an exception" do
      expect{ Cuttlebone::Controller.new(valid_session, 'invalid_context') }.should raise_error(Cuttlebone::InvalidContextError)
    end
  end
end
