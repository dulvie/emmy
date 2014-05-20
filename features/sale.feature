Feature: Create and complete a sale

  Scenario: Create a new sale
    Given I am a signed in user
    And database posts exists to create a new sale
    And I visit sales_path
    And I click "Create Sale"
    And I fill in valid "sale" data
    And I click "Create Sale"
    Then I should see "Sale was sucessfully created."
