Feature: Create/Update Manual transactions
  In order to adjust product stock numbers
  a user should be able to create and update manual
  transactions.

  Scenario: create
    Given I am a signed in user
    And a product and warehouse exists
    And I visit manuals_path
    And I click "Create Manual"
    And I fill in data for a manual transaction
    And I click "Create Manual"
    Then I should see "Manual transaction was successfully created."
    And Resque should perform work
    And warehouse should have test products
