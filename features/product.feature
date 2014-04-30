Feature: Crud products
  In order to handle products
  a user should be able to create/read/update/delete product(s)
  where read is included in update.

  Scenario: create
    Given I am a signed in user
    And I visit products_path
    And I click "Create Product"
    And I fill in valid "product" data
    And I click "Create Product"
    Then I should see "product was successfully created."

  Scenario: update
    Given I am a signed in user
    And a "product" with "name" equals to "test product" exists
    And I visit products_path
    And I click edit link for "test product" product
    And I fill in "product_name" with "test product 2"
    And I click "Update Product"
    Then I should see "Product was successfully updated."
    And I should see "test product 2"

  @javascript
  Scenario: delete
    Given I am a signed in user
    And a "product" with "name" equals to "test product" exists
    And I visit products_path
    And I click delete link for "test product" product
    And I confirm the alertbox
    Then I should see "Product was successfully deleted."

