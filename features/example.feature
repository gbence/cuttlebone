@console @example
Feature: a simple example
  In order to be able to manage a simple todo list
  As a programmer
  I want to create cuttlebone program

  Scenario: starting with no defined contexts
    Given no cuttlebone code
    When I start an "x" session
    Then I should get an error

  Scenario: starting with an existing context
    Given the following cuttlebone code:
      """
      context "x" do
      end
      """
    When I start an "x" session
    Then I should see an empty prompt
    And I should be in context "x"

  Scenario: starting with a missing context
    Given the following cuttlebone code:
      """
      context "x" do
      end
      """
    When I start a "y" session
    Then I should get an error

  Scenario: starting a context with prompt defined
    Given the following cuttlebone code:
      """
      context "x" do
        prompt { "prompt" }
      end
      """
    When I start an "x" session
    Then I should see "prompt" as prompt

  Scenario: invoking a simple command
    Given the following cuttlebone code:
      """
      context "x" do
        command /^y$/ do
          self
        end
      end
      """
    When I start an "x" session
    And I call command "y"
    Then I should see an empty prompt
    And I should be in context "x"
