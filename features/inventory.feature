Feature: Crud inventory
  In order to handle inventory
  a user should be able to create/read/update/delete inventory
  where read is included in update.

  Scenario: create
    Given database is clean
    Given I am a signed in user
    And a "warehouse" with "name" equals to "test warehouse" exists
    And a "batch" with "name" equals to "test batch" exists
    And I visit inventories_path for "test-organization"
    And I click "Create Inventory"
    And I fill in valid "inventory" data
    And I click "Create Inventory"
    Then I should see "Inventory was successfully created."

  Scenario: create with invalid data
    Given I am a signed in user
    And a "warehouse" with "name" equals to "test warehouse" exists
    And a "batch" with "name" equals to "test batch" exists
    And I visit inventories_path for "test-organization"
    And I click "Create Inventory"
    And I fill in invalid "inventory" data
    And I click "Create Inventory"
    Then I should see "Failed to create"

  Scenario: start a inventory
    Given I am a signed in user
    Given I have set up a inventory for warehouse "test warehouse"
    And I visit inventories_path for "test-organization"
    Then I should see "not_started"
    And I click edit link for inventory in warehouse "test warehouse" for "test-organization"
    And I click "Start-angular"
    And I visit inventories_path for "test-organization"
    Then I should see " startedx"


  Scenario: close a inventory