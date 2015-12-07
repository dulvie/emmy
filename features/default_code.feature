Feature: Manage default_codes
  In order to handle default_codes
  a user should be able to import and connect default_codes to accounting plan


  Scenario: fail to import tax codes when accounting_plan missing
    Given database is clean
    Given I am a signed in user
    And I visit default_codes_path for "test-organization"
    And I click "Import Automatic coding - codes"
    Then I should see "Accounting plan Missing"

  Scenario: connect default_codes to accounting_plan
    Given I am a signed in user
    Given accounting_plan imported
    And I visit default_codes_path for "test-organization"
    And I click "Import Automatic coding - codes"
    And I fill in valid "default_code" data
    And I click "Create File importer"
    Then I should see "Automatic coding - codes was successfully created."
    Given default_code imported
    Then I should see 7 default_codes connected to accounts in "BAS – Kontoplan 2014"