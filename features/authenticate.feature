Feature: Authentication
  
  Scenario: Authentication with correct credentials
    Given I have a Bugzilla instance for "http://localhost/bugzilla3/" for "test.user@domain.com" with password "testtest"
    Then I should be able to authenticate

  Scenario: Authentication with incorrect credentials
    Given I have a Bugzilla instance for "http://localhost/bugzilla3/" for "test.user@domain.com" with password "testtesttest"
    Then I should not be able to authenticate
