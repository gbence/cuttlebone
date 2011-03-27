When /^I start (?:an? )?"([^"]*)" session on rack$/ do |objects|
  @d = Cuttlebone::Drivers::Rack.new(*(objects.scan(/([^,]{1,})(?:,\s*)?/).flatten))
  Capybara.app = @d.send(:app)
end

When /^I go to "([^"]*)"$/ do |path|
  visit path
end

Then /^I should see "([^"]*)" in the prompt$/ do |text|
  page.should have_xpath('//span[@id="prompt"]', :text => text)
end

