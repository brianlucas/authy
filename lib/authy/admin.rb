class Authy
  module Admin

    # Issues a card for administrative or test purposes.
    # Expects an options hash.
    #
    # == Options:
    #
    #   +limit+             - Integer representing the card limit in cents ($10.00 = 1000).
    #   +balance+           - Integer representing the starting balance.
    #   +velocity_limit+    - Integer representing max amount to spend during velocity_interval
    #   +velocity_interval+ - Integer representing seconds in the velocity interval
    #   +token+             - Optional string that can override a random token
    #
    # == Examples:
    #
    #   Authy.issue_card(limit: 2000000, balance: 0)
    #   Authy.issue_card(token: 'ABCD')
    #
    def issue_card(opts = {})
      limit = opts[:limit] ||
              ENV["DEFAULT_CARD_LIMIT"].to_i || 0

      balance = opts[:balance] || 0

      velocity_limit = opts[:velocity_limit] ||
                       ENV["DEFAULT_VELOCITY_LIMIT"].to_i || 0

      velocity_interval = opts[:velocity_interval] ||
                          ENV["DEFAULT_VELOCITY_INTERVAL"].to_i || 0

      token = opts[:token] ||
              (0...16).map { (65 + rand(26)).chr }.join

      card_id = @cards.insert(
        token: token,
        limit: limit,
        balance: balance,
        velocity_limit: velocity_limit,
        velocity_interval: velocity_interval,
      )

      return @cards.where(id: card_id)
    end

    # Creates a merchant record for test purposes.
    # Expects an options hash.
    #
    # == Options:
    #
    #   +name+             - String representing the merchant name
    #
    # == Examples:
    #
    #   Authy.create_merchant(name: 'Philz')
    #
    def create_merchant(opts = {})
      name = opts[:name]
      return false unless name.is_a? String
      merchant_id = @merchants.insert(
        name: name,
      )
      return @merchants.where(id: merchant_id)
    end
  end
end
