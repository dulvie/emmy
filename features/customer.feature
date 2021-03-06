Feature: Crud customers
  In order to handle customers
  a user should be able to create/read/update/delete customer(s)
  where read is included in update.

  Scenario: create
    Given database is clean
    Given I am a signed in user
    And I visit customers_path for "test-organization"
    And I click "Create Customer"
    And I fill in valid "customer" data
    And I click "Create Customer"
    Then I should see "Customer was successfully created."

  Scenario: create with invalid data
    Given I am a signed in user
    And I visit customers_path for "test-organization"
    And I click "Create Customer"
    And I fill in invalid "customer" data
    And I click "Create Customer"
    Then I should see "Failed to create"

  Scenario: update
    Given I am a signed in user
    And a "customer" with "name" equals to "test customer" exists
    And I visit customers_path for "test-organization"
    And I click edit link for "test customer" customer in "test-organization"
    And I fill in "customer_name" with "test customer 2"
    And I click "Update Customer"
    Then I should see "test customer 2"

  Scenario: Update with invalid data
    Given I am a signed in user
    And a "customer" with "name" equals to "test customer" exists
    And I visit customers_path for "test-organization"
    And I click edit link for "test customer" customer in "test-organization"
    And I fill in invalid "customer" data
    And I click "Update Customer"
    Then I should see "Failed to update"

  @javascript
  Scenario: delete
    Given I am a signed in user
    And a "customer" with "name" equals to "test customer" exists
    And I visit customers_path for "test-organization"
    And I click delete link for "test customer" customer in "test-organization"
    Then I should see "Customer was successfully deleted."
