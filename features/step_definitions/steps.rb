require 'pp'
# schema / definitions

Given /^no cuttlebone code$/ do
  Cuttlebone.definitions.clear
end

Given /^the following cuttlebone code:$/ do |string|
  Given %{no cuttlebone code}
  Cuttlebone.instance_eval(string)
end

# initialization

Given /^a started "([^"]*)" session$/ do |objects|
  When %{I start a #{objects.inspect} session}
end

When /^I start (?:an? )?"([^"]*)" session$/ do |objects|
  @d = Cuttlebone::Drivers::Test.new(*(objects.scan(/([^,]{1,})(?:,\s*)?/).flatten))
end

# invocation

When /^I call command "([^"]*)"$/ do |command|
  @d.call(command)
end

# context related steps

Then /^I should be in context "([^"]*)"$/ do |name|
  @d.active_context.context.to_s.should == name
end

Then /^I should see a terminated session$/ do
  @d.should be_terminated
end

Then /^I should be in the same context$/ do
  @d.previous_active_context.should == @d.active_context
end

Then /^I should not be in the same context$/ do
  @d.previous_active_context.should_not == @d.active_context
end

# output related steps

Then /^I should see "([^"]*)"$/ do |text|
  @d.output.should include(text)
end

# prompt related steps

Then /^I should see "([^"]*)" as prompt$/ do |text|
  @d.prompt.should include(text)
end

Then /^I should see \/([^\/]*)\/ as prompt$/ do |regexp|
  @d.prompt.should match(regexp)
end

Then /^I should see an empty prompt$/ do
  @d.prompt.should be_empty
end

# error related steps

Then /^I should see an error$/ do
  @d.error.should_not be_blank
end

Then /^I should get an error$/ do
  @d.internal_error.should_not be_nil
  @d.internal_error.should_not be_empty
end

