require File.expand_path(File.join(File.dirname(__FILE__), '/spec_helper'))

describe Cuttlebone::Definition do
  let(:valid_context_identifier) { :c }
  let(:valid_options)            { {} }
  let(:valid_block)              { proc { command('x') {} } }

  context "given valid but meaningless parameters" do
    subject { Cuttlebone::Definition.new(valid_context_identifier, valid_options, &valid_block) }

    it "should match to the context id given" do
      subject.should match(valid_context_identifier)
    end

    it "should return prompt" do
      subject.should respond_to(:prompt)
      subject.prompt.should be_a(Proc)
    end
  end

  context "given class for context matcher" do
    let(:klass)     { Class.new(Object) }
    let(:instance1) { klass.new }
    let(:instance2) { klass.new }
    let(:other_instance) { Object.new }
    let(:subclass)  { Class.new(klass) }
    let(:instance3) { subclass.new }
    subject { Cuttlebone::Definition.new(klass, valid_options, &valid_block) }

    it "should match instances" do
      subject.should match(instance1)
      subject.should match(instance2)
      subject.should_not match(other_instance)
    end

    it "should match subclass instances" do
      subject.should match(instance3)
    end
  end

  context "given several commands" do
    let(:drop_block) { proc { drop } }
    let(:add_block)  { proc { |arg| add arg.to_s.to_sym } }
    let(:definition_with_several_commands) do
      proc do
        command 'nil_will_be_self' do
        end
        command 'drop' do
          drop
        end
        command 'add x' do
          add 0
        end
        command 'replace x' do
          replace :x
        end
        command 'self' do
          self
        end
        command 'double_action_error' do
          add :x
          drop
        end
      end
    end

    subject { Cuttlebone::Definition.new(valid_context_identifier, valid_options, &definition_with_several_commands) }

    it "should have several commands" do
      subject.should have(6).commands
    end

    it "should parse new commands" do
      subject.command(/new command/) { self }
      subject.should have(7).commands
    end

    it "should return the specific block for a command" do
      subject.command /^add (.)$/, &add_block

      subject.proc_for('add x').should_not == [add_block, []]
      subject.proc_for('add y').should == [add_block, ['y']]
    end

    it "should parse arguments properly" do
      subject.command /^add (.)(.)?$/, &(proc{|a,b|})

      subject.proc_for('add y').last.should == ['y', nil]
      subject.proc_for('add yz').last.should == ['y', 'z']
    end

    it "should return an error for unmatched commands" do
      expect{ subject.proc_for('unmatched') }.should raise_error(Cuttlebone::UnknownCommandError)
    end

    it "should return no error on semantically wrong commands" do
      expect{ subject.proc_for('double_action_error') }.should_not raise_error
    end
  end
end
