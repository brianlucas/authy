# Transaction Authyr

*Purpose: Authy a transaction against a persistent datastore.*

Simulates a credit card transaction by a merchant against a financial institution. 

Author: Brian Lucas

## Pre-requisites
- Ruby 2.3.0+ 
- Bundler
- SQLite

## Getting started
In the directory, run

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

Try running the example file (`ruby authy_example.rb`) for a quick primer.

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

*Add merchant*:
```
name = "Peets Coffee"
merchant = authy.create_merchant(name: name)
```

*Issue card*:
Issues a card for administrative or test purposes.
Expects an options hash.

```
name = "Peets Coffee"
merchant = authy.create_merchant(name: name)
```

## Tests
A full test-suite is available.
RECREATE_DATABASE=true rspec

Run `rspec` from the project root to run all unit and integration tests.