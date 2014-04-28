Feature: Crud warehouses
  In order to handle warehouses
  a user should be able to create/read/update/delete warehouse(s)

  Scenario: create
    Given I am a signed in user
    And I visit warehouses_path
    And I click "Create Warehouse"
    And I fill in valid "warehouse" data
    And I click "Create Warehouse"
    Then I should see "Warehouse was successfully created."
