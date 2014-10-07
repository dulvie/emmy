Feature: An admin should be able to invite a user into their organization.

  Scenario: Add existing user.
    Given a "organization" with "name" equals to "test organization" exists
    And I am signed in as an admin on "test organization"
    And a user with email "other@example.com" exists and have no roles on "test organization"
    And I click "Users"
    And I click "Invite User"
    And I fill in "services_invite_email" with "other@example.com"
    And I click "Create Invite"
    Then I should see "Invite was successfully created."
    And a user with email "other@example.com" should have the "staff" role on "test organization"

  Scenario: Add new user.
    Given a "organization" with "name" equals to "test organization" exists
    And I am signed in as an admin on "test organization"
    And a "user" with "email" "other@example.com" does not exists
    And I click "Users"
    And I click "Invite User"
    And I fill in "services_invite_email" with "other@example.com"
    And I click "Create Invite"
    Then I should see "Invite was successfully created."
    And a user with email "other@example.com" should have the "staff" role on "test organization"
