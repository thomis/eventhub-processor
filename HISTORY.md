## 0.7.0 / 2022-11-10

* Add: Use of standard ruby style guide, linter, and formatter
* Add: Code coverage
* Edit: Allow additional property to support cloud migration: amqp port and ssl

## 0.6.6 / 2017-11-07

* Edit: rspec dependency update

## 0.6.5 / 2017-10-05

* Fix: URL encode password for rest calls

## 0.4.0 / 2014-11-20

* Extracted code to eventhub-components gem

## 0.3.1 / 2014-11-13

* Bug fixes
  * Typo in heartbeat structure

## 0.3.0 / 2014-11-13

* Improvements
  * New heartbeat structure, sends a heartbeat during shutdown
  * New execution history
  * New exceptin class "EventHub::NoDeadletterException" to skip automated deadlettering
* Bug fixes
  * None
* Internal improvements
  * More modularized code and therefore easier to test
