Feature: Entries

Scenario: Routes
    Then the application should respond to 'GET /entries'
    And the application should respond to 'POST /entries'
    And the application should respond to 'GET /entries/ID/ACTION'
    And the application should respond to 'GET /entries/new'
    And the application should respond to 'GET /entries/ID'
    And the application should respond to 'POST /entries/ID'

Scenario: Creating a new Entry
    When I POST data to '/entries'
    Then the response should be '302'
    And a new Entry should be created in the database

    