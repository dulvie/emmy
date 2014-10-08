Feature: A user should be able to update their profile.

  Scenario: update password
    Given a user with email "user@example.com" and password "abc123" exists
    And I sign in as "user@example.com" with password "abc123"
    And I click "Profile"
    And I fill in "user_password" with "123abc"
    And I fill in "user_password_confirmation" with "123abc"
    And I click "Update User"
    Then I should see "Your profile was successfully updated."
    And a user with email "user@example.com" should have password "123abc"

  Scenario: update locale
    Given a user with email "user@example.com" and password "abc123" exists
    And a user with email "user@example.com" has "default_locale" set to "en"
    And I sign in as "user@example.com" with password "abc123"
    And I click "Profile"
    And I choose "user_default_locale_se"
    And I click "Update User"
    Then I should see "Din profil uppdaterades."
    And a user with email "user@example.com" should have "default_locale" set to "se"
