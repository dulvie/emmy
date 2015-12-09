Feature: Manage templates
  In order to handle template
  a user should be able to import, create and delete templates


  Scenario: fail to import templates when accounting_plan missing
    Given database is clean
    Given I am a signed in user
    And I visit templates_path for "test-organization"
    Then I should see "Accounting plan Missing"

  @javascript
  Scenario: import templates when accounting_plan is present
    Given I am a signed in user
    Given accounting_plan imported
    And I visit templates_path for "test-organization"
    And I click "Import Templates" for "BAS – Kontoplan 2014" in "test-organization"
    Then I should see "Bankkostnad"
    Then I should see 7 templates for "BAS – Kontoplan 2014"

  Scenario: create
    Given database is clean
    Given I am a signed in user
    Given accounting_plan imported
    And I visit templates_path for "test-organization"
    And I click "Create Template"
    And I fill in valid "template" data
    And I click "Create Template"
    Then I should see "Template was successfully created."
    And I click "Create Template Item"
    And I fill in valid "template_item" data
    And I click "Create Template item"
    Then I should see "Template Item was successfully created."

  @javascript
  Scenario: delete
    Given I am a signed in user
    Given accounting_plan imported
    And I visit templates_path for "test-organization"
    And I click "Import Templates" for "BAS – Kontoplan 2014" in "test-organization"
    And I click delete link for "Bankkostnad" template in "test-organization"
    Then I should see "Template was successfully deleted."