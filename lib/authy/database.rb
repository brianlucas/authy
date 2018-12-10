class Authy
  module Database

    # Connects to the database using the Sequel database driver
    # Expects name to adhere to be a SQLite3 db tied to environment
    def connect_database
      connection = Sequel.connect("sqlite://#{_db_name}")
      return connection
    end

    # Runs the DB creation / migration step when requested.
    #
    # == Tables:
    #
    #   +cards+             - Card details and information including balance, limit
    #   +txns+              - Card transactions
    #   +merchants+         - Merchant details including name
    #   +locks+             - Mutex locking table
    #
    def setup_db
      @database.create_table :merchants do
        primary_key :id
        String :name
      end

      @database.create_table :cards do
        primary_key :id
        String :token, :unique => true, :null => false
        Integer :limit, :null => false
        Integer :balance, :null => false
        Integer :velocity_limit
        Integer :velocity_interval
      end

      @database.create_table :txns do
        primary_key :id
        Integer :card_id, :null => false
        Integer :merchant_id, :null => false
        Integer :amount, :null => false
        DateTime :created_at, :null => false
      end

      @database.create_table :locks do
        String :id, :unique => true, :null => false
        DateTime :created_at
      end

      return true
    end

    # Drops the DB
    def drop_db
      FileUtils.rm _db_name
      @database = connect_database
    end

    # Acquires a lock and wraps the block
    # around a DB transaction to reduce
    # contention and enable atomic operations
    # when updating balances and writing transactions
    def db_lock(id, duration = 5)
      start = Time.now
      locks = @database.from(:locks)
      while true
        if start < Time.now - duration
          @logger.error("Could not acquire a lock for #{id}")
          # TO-DO: Safeguard to prune old locks
          # This will be necessary if deadlocks are encountered
          # locks.where { created_at < (Time.now - duration) }.delete
          break
        end
        begin
          locks.insert(id: id, created_at: Time.now)
          @database.transaction do
            yield
          end
          locks.where(id: id).delete
          break
        rescue Sequel::UniqueConstraintViolation
          sleep(0.1)
        end
      end
    end

    private

    def _db_name
      "#{@environment}.db"
    end
  end
end
