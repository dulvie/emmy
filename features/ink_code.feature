Feature: Manage ink_codes
  In order to handle ink_codes
  a user should be able to import and connect ink_codes to accounting plan

  Scenario: fail to import ink codes when accounting_plan missing
    Given database is clean
    Given I am a signed in user
    And I visit ink_codes_path for "test-organization"
    And I click "Import Declaration - Ink codes"
    Then I should see "Accounting plan Missing"

  Scenario: connect ink_codes to accounting_plan
    Given I am a signed in user
    Given accounting_plan imported
    And I visit ink_codes_path for "test-organization"
    And I click "Import Declaration - Ink codes"
    And I fill in valid "ink_code" data
    And I click "Create File importer"
    Then I should see "Declaration - Ink codes was successfully created."
    Given ink_code imported
    Then I should see 20 accounts in "BAS – Kontoplan 2014" not connected to INK codes