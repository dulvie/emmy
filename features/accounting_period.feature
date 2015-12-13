Feature: Manage accounting_periods
  In order to handle accounting_period
  a user should be able to create accounting_period

  Scenario: fail to open accounting_periods when accounting_plan missing
    Given database is clean
    Given I am a signed in user
    And I visit accounting_periods_path for "test-organization"
    And I click "Create Accounting period"
    Then I should see "Accounting plans Missing"

  @javascript
  Scenario: create
    Given database is clean
    Given I am a signed in user
    Given accounting_plan imported
    And I visit accounting_periods_path for "test-organization"
    And I click link "Create Accounting period"
    And I fill in valid "accounting_period" data
    And I click button "Create Accounting period"
    Then I should see "Accounting period was successfully created."

