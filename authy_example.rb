require_relative "lib/authy"

ENV_FILE = "default.env"

# First, drop and recreate the database
db = Authy.new(env_file: ENV_FILE)
db.drop_db
db.setup_db

# Next, create an instance to use
authy = Authy.new(env_file: ENV_FILE)

merchant_name = authy.create_merchant(name: "Acme Corp").get(:name)
card = authy.issue_card
amount = 100

success = authy.authorize(card.get(:token), amount, merchant_name)
if success
  puts "Authorization succeeded"
end
