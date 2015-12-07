Feature: Manage tax_codes
  In order to handle tax_codes
  a user should be able to import and connect tax_codes to accounting plan


  Scenario: fail to import tax codes when accounting_plan missing
    Given database is clean
    Given I am a signed in user
    And I visit tax_codes_path for "test-organization"
    And I click "Import Vat, soc.fees - codes"
    Then I should see "Accounting plan Missing"

  Scenario: connect tax_codes to accounting_plan
    Given I am a signed in user
    Given accounting_plan imported
    And I visit tax_codes_path for "test-organization"
    And I click "Import Vat, soc.fees - codes"
    And I fill in valid "tax_code" data
    And I click "Create File importer"
    Then I should see "Vat, soc.fees - codes was successfully created."
    Given tax_code imported
    Then I should see 18 tax_codes connected to accounts in "BAS – Kontoplan 2014"