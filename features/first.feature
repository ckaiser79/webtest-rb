#encoding: utf-8
Feature: Showcase the simplest possible Cucumber scenario
  In order to verify that cucumber is installed and configured correctly
  As an aspiring BDD fanatic
  I should be able to run this scenario and see that the steps pass (green like a cuke)

  Scenario: Cutting vegetables

  Scenario Outline:
    Given a cucumber that is <size> cm long
    When I cut it in halves
    Then I have two cucumbers
    And both are <halfSize> cm long
    Examples:
      | size | halfSize |
      | 30   | 15       |
      | 10   | 5        |
      | 0    | 0        |


