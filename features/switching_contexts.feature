Feature: switching between contexts
  In order to be able to manage my todo list
  As a programmer
  I want to switch between cuttlebone contexts

  Background:
    Given the following cuttlebone code:
      """
      context 'x' do
        command 'q' do
          drop
        end
        command 'y' do
          replace 'y'
        end
        command 'yy' do
          add 'y'
        end
        command 'x' do
          self
        end
        command 'xx' do
          add 'x'
        end
        command 'r' do
          replace 'x'
        end
      end

      context 'y' do
        command 'q' do
          drop
        end
        command 'y' do
          self
        end
      end
      """

  Scenario: quitting
    Given a started "x" session
    When I call command "q"
    Then I should see a terminated session

  Scenario: replacing current context
    Given a started "x" session
    When I call command "y"
    Then I should be in context "y"

  Scenario: returning the same context
    Given a started "x" session
    When I call command "x"
    Then I should be in the same context

  Scenario: replacing with a similar context
    Given a started "x" session
    When I call command "r"
    Then I should not be in the same context

  Scenario: entering into a new context
    Given a started "x" session
    When I call command "yy"
    Then I should be in context "y"

  Scenario: dropping previously built context
    Given a started "x" session
    When I call command "yy"
    And I call command "q"
    Then I should be in context "x"

  Scenario: consume multiple contexts and quit
    Given a started "x,y,y,x" session
    When I call command "q"
    And I call command "q"
    And I call command "q"
    Then I should be in context "x"
    When I call command "q"
    Then I should see a terminated session
