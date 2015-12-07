Given(/^ink_code imported$/) do
  Rails.logger.level = 4
  o = Organization.find_by_name("test organization")
  assert o, "no organization found"
  u = User.find_by_name 'testuser'
  assert u, "no user found"
  a = AccountingPlan.find_by_name "BAS – Kontoplan 2014"
  assert a, "no accounting plan found"
  i = InkCode.all
  ink_code_creator = Services::InkCodeCreator.new(o, u, i, a)
  ink_code_creator.execute('load and connect', InkCode::DIRECTORY, 'INK2_15_ver1.csv')
  i = InkCode.all
  assert_equal 78, i.size
end

Then /^I should see (\d+) accounts in "(.*?)" not connected to INK codes$/ do |nbr, accounting_plan|
  a = AccountingPlan.find_by_name accounting_plan
  accounts = a.accounts.where('ink_code_id ISNULL')
  assert_equal nbr.to_i, accounts.size
  accounts.each do |account|
    puts "#{account.number} #{account.description} \n"
  end
end

def ink_code_valid_form_data
  select "INK2_15_ver1.csv", from: 'file_importer_file'
  select "load and connect", from: 'file_importer_type'
  select "BAS – Kontoplan 2014", from: 'file_importer_accounting_plan'
end