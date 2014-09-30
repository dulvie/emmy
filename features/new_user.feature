Feature: Sign up and create an organisation.
  In order to access the application
  a user should be able to register an account.
  And register a new organisation.
  And edit the data of the organisation.


  Scenario: create_user
    Given I do not have a user session
    And I am on the home page
    And I click "Sign in"
    And I click "Sign up"
    And I fill in valid "user" data
    And I click "Sign up"
    Then I should see "You have signed up successfully."

  Scenario: create_organisation
    Given I am a signed in user without an organization
    And I visit the dashboard
    And I fill in valid "organization" data
    And I click "Create Organization"
    Then I should see "Organization was successfully created."
