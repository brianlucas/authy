require_relative "../lib/authy"
require "fileutils"

ENV_FILE = ENV["ENV_FILE"] || "test.env"

RSpec.describe Authy do
  before(:all) do
    # First, remove the database if necessary
    if ENV["RECREATE_DATABASE"]
      authorize = Authy.new(env_file: ENV_FILE)
      authorize.drop_db
      authorize.setup_db
    end
    # Next, instantiate new instance of auth class
    @authorize = Authy.new(env_file: ENV_FILE)
  end

  context "Configuration" do
    it "should instantiate an instance with correct environment" do
      expect(@authorize).to be_an_instance_of(Authy)
      expect(@authorize.environment).to eq("test")
      expect(ENV["DEFAULT_CARD_LIMIT"].to_i).not_to eq(0)
    end
  end

  context "Administration" do
    it "should issue a card with default values [admin only]" do
      @card = @authorize.issue_card
      expect(@card.get(:limit)).to eq(ENV["DEFAULT_CARD_LIMIT"].to_i)
    end
    it "should issue a card with non-default values [admin only]" do
      # amount of $15,000
      limit = 1500000
      @card = @authorize.issue_card(limit: limit)
      expect(@card.get(:limit)).to eq(limit)
    end
    it "should create a merchant entry [admin only]" do
      name = "Peets Coffee"
      @merchant = @authorize.create_merchant(name: name)
      expect(@merchant.get(:name)).to eq(name)
    end
  end

  context "Authorization" do
    before(:all) do
      @merchant_name = @authorize.merchants.first[:name]
      @token = @authorize.issue_card.get(:token)
    end
    it "should show a zero balance" do
      expect(@authorize.balance(@token)).to eq(0)
    end
    it "should return true with a zero amount" do
      expect(@authorize.authorize(@token, 0, @merchant_name)).to eq(true)
    end
    it "should charge a dollar to the credit card" do
      @authorize.authorize(@token, 100, @merchant_name)
      expect(@authorize.balance(@token)).to eq(100)
    end
    it "should refund a dollar to the credit card" do
      @authorize.authorize(@token, -100, @merchant_name)
      expect(@authorize.balance(@token)).to eq(0)
    end
    it "should return false with invalid token" do
      expect(@authorize.authorize("invalid_token", 0, @merchant_name)).to eq(false)
    end
    it "should throw an error with bad amount" do
      @authorize.authorize(@token, "bad_amount", @merchant_name)
      expect(@authorize.balance(@token)).to eq(0)
    end
  end

  context "Stress testing" do
    before(:all) do
      env_file = "test.env"
      # Instantiate new instance of auth class
      @concurrent = Authy.new(env_file: env_file)
      @merchant_name = @concurrent.merchants.first[:name]
      @limit = 2500000
      @token = "ABCD"
      # Let's check if this card exists before issuing it
      if @concurrent.cards.where(token: @token).count == 0
        @token = @concurrent.issue_card(token: @token, limit: @limit)
          .get(:token)
      end
    end
    it "should work with large numbers of requests" do
      for value in (1..100)
        @concurrent.authorize(@token, 50000, @merchant_name)
        sleep(0.1)
      end
      expect(@concurrent.balance(@token)).to eq(@limit)
    end
  end
end
