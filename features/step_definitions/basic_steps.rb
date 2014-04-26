#require 'minitest/unit'
#World(MiniTest::Assertions)

Given /^I am on the home page$/  do
  visit "/"
end

Then /^I should see "(.*?)"$/ do |string|
  assert_equal page.has_content?(string), true
end


