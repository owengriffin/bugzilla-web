require 'lib/bugzilla.rb'

Given /^I have a Bugzilla instance for "([^\"]*)" for "([^\"]*)" with password "([^\"]*)"$/ do |arg1, arg2, arg3|
  $bugzilla = Bugzilla.new(arg1, arg2, arg3)
end

Then /^I should be able to authenticate$/ do
  fail "Unable to authenticate" if not $bugzilla.authenticate
end

Then /^I should not be able to authenticate$/ do
  fail "Able to authenticate" if $bugzilla.authenticate
end

Given /^I have authenticated$/ do
  fail "Unable to authenticate" if not $bugzilla.authenticate
end

When /^I count the number of bugs$/ do
  $count = $bugzilla.count
end

When /^I post a bug assigned to "([^\"]*)"$/ do |arg1|
  $bug_id = $bugzilla.post("summary", "description", arg1)
end

Then /^the count has incremented$/ do
  fail "The count has not incremented" if $bugzilla.count != $count + 1
end

Then /^the new bug is assigned to "([^\"]*)"$/ do |arg1|
  bugs = $bugzilla.assigned_to(arg1)
  found = false
  bugs.each do |bug|
    found = true if bug["id"] == $bug_id.to_i
  end
  fail "Unable to find bug #{$bug_id} in assignee list" if not found
end
