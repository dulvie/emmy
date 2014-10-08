Feature: An admin should be able to add and remove roles to/from users
  of their organization.

  Scenario: Add a role
    Given a "organization" with "name" equals to "test organization" exists
    And I am signed in as an admin on "test organization"
    And a user with the email "other@example.com" exists and have the role "staff" on "test organization"
    And I click "Users"
    And I click "other@example.com"
    And I check "Admin"
    And I click "Update roles"
    Then I should see "User roles was successfully updated."
    And a user with email "other@example.com" should have the "admin" role on "test organization"

  Scenario: Remove a role
    Given a "organization" with "name" equals to "test organization" exists
    And I am signed in as an admin on "test organization"
    And a user with the email "other@example.com" exists and have the role "admin" on "test organization"
    And I click "Users"
    And I click "other@example.com"
    And I uncheck "Admin"
    And I click "Update roles"
    Then I should see "User roles was successfully updated."
    And a user with email "other@example.com" should not have the "admin" role on "test organization"
