class Authy
  attr_reader :environment, :merchants, :cards
  attr_reader :merchants

  # Takes an environment file string which includes
  # ENVIRONMENT, DEFAULT_CARD_LIMIT, DEFAULT_VELOCITY_LIMIT,
  # and LOG_LEVEL
  def initialize(env_file: "default.env")
    extend Authy::Database # ORM fns
    extend Authy::Admin # Card, Merchant fns

    @environment = _env(env_file)
    @logger = _logger(ENV["LOG_LEVEL"])

    @database = connect_database
    @cards = @database.from(:cards)
    @txns = @database.from(:txns)
    @merchants = @database.from(:merchants)
  end

  # Basic validation and sanitization
  def validate(token, amount, merchant_name)
    @logger.debug("Validating token: #{token}")
    card = @cards.where(token: token).get(:id)
    return false unless card

    @logger.debug("Validating amount: #{token}")
    return false unless amount.is_a? Integer

    @logger.debug("Validating merchant_name: #{merchant_name}")
    merchant = @merchants.where(name: merchant_name).get(:id)
    return false unless merchant

    return true
  end

  # Main authorize method which expects
  # <string> token, <integer> amount,
  # and <string> merchant name
  def authorize(token, amount, merchant_name)
    validated = validate(token, amount, merchant_name)
    return false unless validated

    result = false

    # Block for a period until token is ready to process
    # and wrap this in a DB transaction block
    db_lock(token, duration = 15) do
      card = @cards.where(token: token)
      limit = card.get(:limit)
      # Ensure we want to proceed
      if amount <= (limit - balance(token))
        # Fetch merchant to normalize value
        merchant = @merchants.where(name: merchant_name)
        # Insert the transaction
        result = @txns.insert(
          card_id: card.get(:id),
          merchant_id: merchant.get(:id),
          amount: amount,
          created_at: Time.now,
        )
        # Sum the balance of all card transactions
        new_balance = @txns.where(card_id: card.get(:id))
          .sum(:amount)
        result = true if card.update(balance: new_balance)
      end
    end
    return result
  end

  # Retrieve the balance of the card
  def balance(token)
    return @cards.where(token: token).get(:balance)
  end

  private

  # Load an env_file and inject into environment
  # via ENV['value']
  def _env(env_file)
    result = Dotenv.load(env_file)
    environment = ENV["ENVIRONMENT"]
    return environment
  end

  # Configure a logger and logging level
  def _logger(level)
    logger = Logger.new(STDOUT)
    logger.level = Object.const_get("Logger::#{level}")
    return logger
  end
end

require "sqlite3"
require "dotenv"
require "logger"
require "sequel"
require "fileutils"

require_relative "authy/database"
require_relative "authy/admin"
