@browser @wip
Feature: rack compatibility
  In order to manage my todo list through the web
  As a programmer
  I want to connect to a cuttlebone web-server

  Background:
    Given the following cuttlebone code:
      """
      context "x" do
        prompt { 'prompt' }
        command(?y) { output 'ok' }
      end
      """

  Scenario: start a rack on top of cuttlebone
    When I start an "x" session on rack
    And I go to "/"
    Then I should see "prompt" in the prompt
