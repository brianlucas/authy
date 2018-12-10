# Authy

*Purpose: Authorize a transaction against a persistent datastore.*

Simulates a credit card transaction by a merchant against a financial institution. 

Includes card and merchant provisioning features, locks to prevent concurrent writes, and a reasonable test suite.

Author: Brian Lucas

## Pre-requisites
- Ruby 2.3.0+ 
- Bundler
- SQLite

## Getting started
1. Clone this repo and install dependencies

```
# bundle install

bundle install
The latest bundler is 1.16.2, but you are currently running 1.15.4.
To update, run `gem install bundler`
Using bundler 1.15.4
Using byebug 10.0.2
Using diff-lcs 1.3
Using rspec-support 3.8.0
Using sequel 5.15.0
Using sqlite3 1.3.13
Using rspec-core 3.8.0
Using rspec-expectations 3.8.2
Using rspec-mocks 3.8.0
Using rspec 3.8.0
Bundle complete! 4 Gemfile dependencies, 10 gems now installed.
Use `bundle info [gemname]` to see where a bundled gem is installed.
```

2. Set up the database (via `RECREATE_DATABASE=true rspec`) or the example.
3. Run tests via `rspec`.  Simulate concurrent tests via `rspec & rspec`.
4. Try running the example file (`ruby authy_example.rb`) for a quick primer.

#### Database
Authy uses Sequel for database functions. 

```
authorize = Authy.new(env_file: ENV_FILE)
authorize.drop_db
authorize.setup_db
```

You can easily populate a test database by running:

```
RECREATE_DATABASE=true rspec
```

## Usage

```
auth = Authy.new(env_file: 'default.env')
success = authy.authorize(<token>, <amount>, <merchant name>)
if success
  puts "Authorization succeeded"
end
```

### *Add merchant*:

Creates a merchant record for test purposes.
Expects an options hash.
```
Options:
   +name+             - String representing the merchant name

 == Examples:

   Authy.create_merchant(name: 'Philz')
```

```
name = "Peets Coffee"
merchant = authy.create_merchant(name: name)
```

### *Issue card*:

Issues a card for administrative or test purposes.
Expects an options hash.
```
Options:
   +limit+             - Integer representing the card limit in cents ($10.00 = 1000).
   +balance+           - Integer representing the starting balance.
   +velocity_limit+    - Integer representing max amount to spend during velocity_interval
   +velocity_interval+ - Integer representing seconds in the velocity interval
   +token+             - Optional string that can override a random token
```
Examples:
```
   card = authy.issue_card(limit: 2000000, balance: 0)
   card = authy.issue_card(token: 'ABCD')
```

## Tests
A full test-suite is available.
RECREATE_DATABASE=true rspec

Run `rspec` from the project root to run all unit and integration tests.

```
$ rspec
.....D, [2018-12-10T09:49:48.844916 #85049] DEBUG -- : Validating token:
...

Finished in 10.91 seconds (files took 0.32723 seconds to load)
11 examples, 0 failures
```

## To-do's
- Implement a velocity limit and velocity interval as a form of fraud prevention.  Set a maxiumum limit that can be authorized in a period of time.