Feature: An admin should be able to invite a user into their organization.

  Scenario: Add existing user.
    Given a "organization" with "name" equals to "test organization" exists
    And I am signed in as an admin on "test organization"
    And a user with email "other@example.com" exists and have no roles on "test organization"
    And I click "Users"
    And I click "Invite"
    And I fill in "email" with "other@example.com"
    And I click "Add User"
    Then I should see "User added to organization."
    And a user with email "other@example.com" should have the "staff" role on "test organization"
