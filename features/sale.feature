Feature: Ensure correct state change buttons are visible
  Background:
    Given database is clean
    And I am a signed in user

  Scenario: When creating, create and no other should be visible
    Given I visit sales_path
    And I click "Create Sale"
    Then I should see a button with text "Create Sale"
    And I should not see a button with text "Deliver"
    And I should not see a button with text "Pay"
    And I should not see a button with text "Mark item complete"
    And I should not see a button with text "Mark complete"

  Scenario: When adding products, show mark_item_complete and others.
    Given a fresh sale exists
    And I visit sales_path
    And I click the first sale
    Then I should see a button with text "Mark item complete"
    And I should see a button with text "Deliver"
    And I should see a button with text "Pay"
    And I should not see a button with text "Mark complete"
    And I should not see a button with text "Create Sale"

  Scenario: When sale state is item_complete show next state buttons
    Given a sale in state item_complete with some one sale_item
    And I visit sales_path
    And I click the first sale
    Then I should see a button with text "Start processing"
    And I should see a button with text "Deliver"
    And I should see a button with text "Pay"
    And I should not see a button with text "Mark item complete"
    And I should not see a button with text "Mark complete"
    And I should not see a button with text "Create Sale"

  Scenario: When sale state is item_complete show next state buttons
    Given a sale in state start_processing
    And I visit sales_path
    And I click the first sale
    Then I should see a button with text "Mark complete"
    And I should see a button with text "Deliver"
    And I should see a button with text "Pay"
    And I should not see a button with text "Mark item complete"
    And I should not see a button with text "Start processing"
    And I should not see a button with text "Create Sale"

  Scenario: When sale state is start_processing and is delivered
    dont show deliver button
    Given a sale in state start_processing and delivered
    And I visit sales_path
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
    And I visit sales_path
    And I click the first sale
    Then I should see a button with text "Mark complete"
    And I should see a button with text "Deliver"
    And I should not see a button with text "Pay"
    And I should not see a button with text "Mark item complete"
    And I should not see a button with text "Start processing"
    And I should not see a button with text "Create Sale"
