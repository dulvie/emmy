Feature: Ensure correct state change buttons are visible
  Background:
    Given database is clean
    Given a "organization" with "name" equals to "test organization" exists
    And I am signed in as an admin on "test organization"
    And a "customer" with "name" equals to "test customer" exists on "test-organization"
    And a "warehouse" with "name" equals to "test warehouse" exists on "test-organization"
    And the warehouse "test warehouse" have a shelf with "100" of the batch "espresso test 2014:04"

  @javascript
  Scenario: When creating, create and no other should be visible
    Given I visit sales_path for "test-organization"
    And I click "Create Sale"
    And I select "test warehouse" as "sale_warehouse_id"
    And I fill in typeahead field "customer_ref" with "test customer"
    And I click "Create Sale"
    Then I should see "Sale was successfully created. "
    And I should not see a button with text "Deliver"
    And I should not see a button with text "Pay"
    And I should not see a button with text "Mark item complete"
    And I should not see a button with text "Mark complete"

  Scenario: When adding products, show mark_item_complete and others.
    Given a fresh sale exists
    And I visit sales_path for "test-organization"
    And I click the first sale
    Then I should see a button with text "Mark item complete"
    And I should see a button with text "Deliver"
    And I should see a button with text "Pay"
    And I should not see a button with text "Mark complete"
    And I should not see a button with text "Create Sale"

  Scenario: When sale state is item_complete show next state buttons
    Given a sale in state item_complete with some one sale_item
    And I visit sales_path for "test-organization"
    And I click the first sale
    Then I should see a button with text "Start processing"
    And I should see a button with text "Deliver"
    And I should see a button with text "Pay"
    And I should not see a button with text "Mark item complete"
    And I should not see a button with text "Mark complete"
    And I should not see a button with text "Create Sale"

  Scenario: When sale state is item_complete show next state buttons
    Given a sale in state start_processing
    And I visit sales_path for "test-organization"
    And I click the first sale
    Then I should see a button with text "Mark complete"
    And I should see a button with text "Deliver"
    And I should see a button with text "Pay"
    And I should not see a button with text "Mark item complete"
    And I should not see a button with text "Start processing"
    And I should not see a button with text "Create Sale"

  Scenario: When sale state is start_processing and is delivered
            dont show deliver button.
    Given a sale in state start_processing and delivered
    And I visit sales_path for "test-organization"
    And I click the first sale
    Then I should see a button with text "Mark complete"
    And I should see a button with text "Pay"
    And I should not see a button with text "Deliver"
    And I should not see a button with text "Mark item complete"
    And I should not see a button with text "Start processing"
    And I should not see a button with text "Create Sale"

  Scenario: When sale state is start_processing and is paid
    dont show deliver button
    Given a sale in state start_processing and paid
    And I visit sales_path for "test-organization"
    And I click the first sale
    Then I should see a button with text "Mark complete"
    And I should see a button with text "Deliver"
    And I should not see a button with text "Pay"
    And I should not see a button with text "Mark item complete"
    And I should not see a button with text "Start processing"
    And I should not see a button with text "Create Sale"
