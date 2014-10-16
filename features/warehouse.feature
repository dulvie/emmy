Feature: Crud warehouses
  In order to handle warehouses
  a user should be able to create/read/update/delete warehouse(s)
  where read is included in update.

  Scenario: create
    Given database is clean
    Given I am a signed in user
    And I visit warehouses_path for "test-organization"
    And I click "Create Warehouse"
    And I fill in valid "warehouse" data
    And I click "Create Warehouse"
    Then I should see "Warehouse was successfully created."

  Scenario: update
    Given I am a signed in user
    And a "warehouse" with "name" equals to "test warehouse" exists
    And I visit warehouses_path for "test-organization"
    And I click edit link for "test warehouse" warehouse in "test-organization"
    And I fill in "warehouse_name" with "test warehouse 2"
    And I click "Update Warehouse"
    Then I should see "Warehouse was successfully updated."
    And I should see "test warehouse 2"

  @javascript
  Scenario: delete
    Given I am a signed in user
    And a "warehouse" with "name" equals to "test warehouse" exists
    And I visit warehouses_path for "test-organization"
    And I click delete link for "test warehouse" warehouse in "test-organization"
    Then I should see "Warehouse was successfully deleted."

