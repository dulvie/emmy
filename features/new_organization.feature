Feature: A superadmin should be able to create a new organization.
  And add a user to that organization.
  And change the role of that user for the new organization to 'admin'
  That user should then be able to create another user for that organization with the role 'staff'

  Scenario: create organization
    Given I am signed in as a superadmin
    And I visit admin_dashboard_path
    And I click "Create Organization"
    And I fill in valid "organization" data
    And I click "Create Organization"
    Then I should see "Organization was successfully created."
    And I should see "Create New User"

  Scenario: Add an admin to an organization
    Given I am signed in as a superadmin
    And a "organization" with "name" equals to "test organization" exists
    And I visit admin_dashboard_path
    And I click "test organization"
    And I click "Create New User"
    And I fill in valid "user" data
    And I click "Create user"
    Then I should see "User was successfully created."
    And a user with the role "admin" on "test organization" should exist
