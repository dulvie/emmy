Feature: Crud suppliers
  In order to handle suppliers
  a user should be able to create/read/update/delete supplier(s)
  where read is included in update.

  Scenario: create
    Given I am a signed in user
    And I visit suppliers_path
    And I click "Create Supplier"
    And I fill in valid "supplier" data
    And I click "Create Supplier"
    Then I should see "supplier was successfully created."

  Scenario: create with invalid data
    Given I am a signed in user
    And I visit suppliers_path
    And I click "Create Supplier"
    And I fill in invalid "supplier" data
    And I click "Create Supplier"
    Then I should see "Failed to create"

  Scenario: update
    Given I am a signed in user
    And a "supplier" with "name" equals to "test supplier" exists
    And I visit suppliers_path
    And I click edit link for "test supplier" supplier
    And I fill in "supplier_name" with "test supplier 2"
    And I click "Update Supplier"
    Then I should see "supplier was successfully updated."
    And I should see "test supplier 2"

  Scenario: Update with invalid data
    Given I am a signed in user
    And a "supplier" with "name" equals to "test supplier" exists
    And I visit suppliers_path
    And I click edit link for "test supplier" supplier
    And I fill in invalid "supplier" data
    And I click "Update Supplier"
    Then I should see "Failed to update"

  @javascript
  Scenario: delete
    Given I am a signed in user
    And a "supplier" with "name" equals to "test supplier" exists
    And I visit suppliers_path
    And I click delete link for "test supplier" supplier
    And I confirm the alertbox
    Then I should see "Supplier was successfully deleted."

