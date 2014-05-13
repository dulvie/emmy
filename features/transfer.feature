Feature: Create and complete a transfer
  between two warehouses.

  Scenario: Create a new transfer
    Given I am a signed in user
    And a product with name "test product" exists
    And a warehouse with name "test from wh" exists
    And the "test from wh" warehouse have "10" of product "test product"
    And a warehouse with name "test to wh" exists
    And I visit transfers_path
    And I click "Create Transfer"
    And I select "test from wh" as "from" warehouse
    And I select "test to wh" as "to" warehouse
    And I fill in "10" as transfer_quantity
    And I select "test product" as "transfer_product_id"
    And I click "Create Transfer"
    Then I should see "Transfer transaction was successfully created."

  Scenario: Send a package
    Given I am a signed in user
    And a warehouse with name "test from wh" exists
    And a warehouse with name "test to wh" exists 
    And a product with name "test product" exists
    And warehouse "test from wh" has a shelf with 10 of product named "test product"
    And a transfer of 10 "test product" product from "test from wh" to "test to wh" is created
    And I visit transfers_path
    And I see "Mark as sent" in the page
    #And I click "Mark as sent" to actually create a transaction from "test from wh"
    And I click "Mark as sent"
    And I wait for resque to perform work
    Then I should see "Verify as received"
    And "test from wh" warehouse should have 0 "test product" products on the shelves
    And "test to wh" warehouse should have 0 "test product" products on the shelves

  Scenario: Receive a package
    Given I am a signed in user

    And a warehouse with name "test from wh" exists
    And a warehouse with name "test to wh" exists
    And a product with name "test product" exists
    And warehouse "test from wh" has a shelf with 10 of product named "test product"
    And a transfer of 10 "test product" product is created and sent from "test from wh" to "test to wh"

    And I visit transfers_path
    #And I click "Verify as received" to actually create a transaction to "test to wh"
    And I click "Verify as received"
    And I wait for resque to perform work
    Then I should see "received"
    And "test from wh" warehouse should have 0 "test product" products on the shelves
    And "test to wh" warehouse should have 10 "test product" products on the shelves
