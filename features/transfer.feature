Feature: Create and complete a transfer
  between two warehouses.

  Scenario: Create a new transfer
    Given database is clean
    Given I am a signed in user
    And a "batch" with "name" equals to "test batch" exists
    And a "warehouse" with "name" equals to "test from wh" exists
    And the "test from wh" warehouse have "10" of batch "test batch"
    And a warehouse with name "test to wh" exists 
    And I visit transfers_path for "test-organization"
    And I click "Create Transfer"
    And I select "test from wh" as "from" warehouse
    And I select "test to wh" as "to" warehouse
    And I fill in "10" as transfer_quantity
    And I select "test batch" as "transfer_batch_id"
    And I fill in "text" as transfer_comments_attributes_0_body
    And I click "Create Transfer"
    Then I should see "Transfer transaction was successfully created."

  Scenario: Send a package
    Given I am a signed in user
    And a warehouse with name "test from wh" exists
    And a warehouse with name "test to wh" exists
    And a batch with name "test batch" exists
    And warehouse "test from wh" has a shelf with 10 of batch named "test batch"
    And a transfer of 9 "test batch" batch from "test from wh" to "test to wh" is created
    And I visit transfers_path for "test-organization" 
    And I see "Send" in the page
    And I click send for organization "test-organization"
    And I visit transfers_path for "test-organization"
    And I see "Receive" in the page
    And I wait for resque to perform work
    Then "test from wh" warehouse should have 1 "test batch" batches on the shelves


  Scenario: Receive a package
    Given I am a signed in user
    And a warehouse with name "test from wh" exists
    And a warehouse with name "test to wh" exists
    And a batch with name "test batch" exists
    And warehouse "test from wh" has a shelf with 10 of batch named "test batch"
    And a transfer of 9 "test batch" batch from "test from wh" to "test to wh" is created
    And I visit transfers_path for "test-organization"
    And I see "Send" in the page
    And I click send for organization "test-organization"
    And I visit transfers_path for "test-organization"
    And I see "Receive" in the page
    And I click receive for organization "test-organization"
    And I wait for resque to perform work
    Then "test from wh" warehouse should have 1 "test batch" batches on the shelves
    Then "test to wh" warehouse should have 9 "test batch" batches on the shelves
