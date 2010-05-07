Feature: Posting new bugs

  Scenario: The number of bugs increases when a new bug is filed
    Given I have a Bugzilla instance for "http://localhost/bugzilla3/" for "test.user@domain.com" with password "testtest"

    And I have authenticated
    When I count the number of bugs
    And I post a bug assigned to "test.user@domain.com"
    Then the count has incremented

  Scenario: The bug appears in the list assigned to me
    Given I have a Bugzilla instance for "http://localhost/bugzilla3/" for "test.user@domain.com" with password "testtest"
    And I have authenticated
    When I count the number of bugs
    And I post a bug assigned to "test.user@domain.com"
    Then the count has incremented
    And the new bug is assigned to "test.user@domain.com"

  Scenario: Posting a bug in a specific product
    Given I have a Bugzilla instance for "http://localhost/bugzilla3/" for "test.user@domain.com" with password "testtest"
    And I have authenticated
    When I count the number of bugs for the "bugzilla-web" product
    And I post a bug assigned to "test.user@domain.com" for the "bugzilla-web" product
    Then the product count has incremented

  Scenario: Posting a bug in a specific component
    Given I have a Bugzilla instance for "http://localhost/bugzilla3/" for "test.user@domain.com" with password "testtest"
    And I have authenticated
    When I count the number of bugs for the "bugzilla-web" product and "component0" component
    And I count the number of bugs for the "bugzilla-web" product and "component1" component
    And I post a bug assigned to "test.user@domain.com" for the "bugzilla-web" product and "component1" compontent
    Then the count for product "bugzilla-web" and component "component1" has incremented
    Then the count for product "bugzilla-web" and component "component1" has not incremented
    
    
    
    
