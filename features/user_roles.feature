Feature: A superadmin should be able to add and remove roles from users.

  Scenario: Add role
    Given I am signed in as a superadmin
    And a "organization" with "name" equals to "test organization" exists
    And a user with the email "staff@example.com" exists and have the role "staff" on "test organization"
    And I visit admin_dashboard_path
    And I click "test organization"
    And I click "users"
    And I see "staff@example.com"
    And I click "staff@example.com"
    And I check "Admin"
    And I click "Update roles"
    Then I should see "User roles was successfully updated."
    And a user with email "staff@example.com" should have the "staff" role on "test organization"
    And a user with email "staff@example.com" should have the "admin" role on "test organization"

  Scenario: Remove a role
    Given I am signed in as a superadmin
    And a "organization" with "name" equals to "test organization" exists
    And a user with the email "staff@example.com" exists and have the role "staff" on "test organization"
    And I visit admin_dashboard_path
    And I click "test organization"
    And I click "users"
    And I see "staff@example.com"
    And I click "staff@example.com"
    And I uncheck "Staff"
    And I click "Update roles"
    Then I should see "User roles was successfully updated."
    And a user with email "staff@example.com" should not have the "staff" role on "test organization"
