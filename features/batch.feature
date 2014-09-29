Feature: Crud batches
  In order to handle batches
  a user should be able to create/read/update/delete batch(es)
  where read is included in update.

  Scenario: create
    Given database is clean
    Given I am a signed in user
    And a couple of "items" exists
    And I visit batches_path
    And I click "Create Batch"
    And I fill in valid "batch" data
    And I click "Create Batch"
    Then I should see "Batch was successfully created."

  Scenario: create with invalid data
    Given I am a signed in user
    And I visit batches_path
    And I click "Create Batch"
    And I fill in invalid "batch" data
    And I click "Create Batch"
    Then I should see "Failed to create"

  Scenario: update
    Given I am a signed in user
    And a "batch" with "name" equals to "test batch" exists
    And I visit batches_path
    And I click edit link for "test batch" batch
    And I fill in "batch_name" with "test batch 2"
    And I click "Update Batch"
    Then I should see "test batch 2"

  Scenario: update with invalid data
    Given I am a signed in user
    And a "batch" with "name" equals to "test batch" exists
    And I visit batches_path
    And I click edit link for "test batch" batch
    And I fill in invalid "batch" data
    And I click "Update Batch"
    Then I should see "Failed to update"

  @javascript
  Scenario: delete
    Given I am a signed in user
    And a "batch" with "name" equals to "test batch" exists
    And I visit batches_path
    And I click delete link for "test batch" batch
    And I confirm the alertbox
    Then I should see "Batch was successfully deleted."

