Feature: Manage accounting plans
  In order to handle accounting plans
  a user should be able to import and read accounting plan
  where read included accounting_classes, accountinging_group and accounts.

  Scenario: import accounting plan
    Given database is clean
    Given I am a signed in user
    And I visit accounting_plans_path for "test-organization"
    And I click "Import Accounting plan"
    And I fill in valid "accounting_plan" data
    And I click "Create File importer"
    Then I should see "Accounting plan was successfully updated."

  Scenario: read accounting plan
    Given I am a signed in user
    Given accounting_plan imported
    And I visit accounting_plans_path for "test-organization"
    Then I should see "BAS – Kontoplan 2014"
    And I click edit link for "BAS – Kontoplan 2014" accounting_plan in "test-organization"
    Then I should see "BAS – Kontoplan 2014"
    Then I should see "Eget kapital och skulder"
    Then I should see "Kassa och bank"
    Then I should see "Goodwill "
    Then I should see 7 accounting_classes in "BAS – Kontoplan 2014"
    Then I should see 70 accounting_groups in "BAS – Kontoplan 2014"
    Then I should see 1198 accounts in "BAS – Kontoplan 2014"