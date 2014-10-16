Feature: Crud Items
  In order to handle items
  a user should be able to create/read/update/delete item(es)
  where read is included in update.

  Scenario: create
    Given database is clean
    Given I am a signed in user
    And a "unit" with "name" equals to "kg" exists
    And a "vat" with "name" equals to "12 procent" exists
    And I visit items_path for "test-organization"
    And I click "Create Item"
    And I fill in valid "item" data
    And I click "Create Item"
    Then I should see "item was successfully created."

  Scenario: create with invalid data
    Given I am a signed in user
    And I visit items_path for "test-organization"
    And I click "Create Item"
    And I fill in invalid "item" data
    And I click "Create Item"
    Then I should see "Failed to create"

  Scenario: update
    Given I am a signed in user
    Given a "item" with "name" equals to "update item" exists
    And I visit items_path for "test-organization"
    And I click edit link for "update item" item in "test-organization"
    And I fill in "item_name" with "test item 2"
    And I click "Update Item"
    Then I should see "Item was successfully updated."
    And I should see "test item 2"

  Scenario: update with invalid data
    Given I am a signed in user
    Given a "item" with "name" equals to "test item" exists
    And I visit items_path for "test-organization"
    And I click edit link for "test item" item in "test-organization"
    And I fill in invalid "item" data
    And I click "Update Item"
    Then I should see "Failed to update"

  @javascript
  Scenario: delete
    Given I am a signed in user
    And a "item" with "name" equals to "test item" exists
    And I visit items_path for "test-organization"
    And I click delete link for "test item" item in "test-organization"
    Then I should see "Item was successfully deleted."


