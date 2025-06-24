# Algorithm/ pseudo code
# 1. display a welcome msg and get the use to input their name 
# 2. retrive the use unput and store it in a veriable for later use
# 3. display hello use name and provide further instruction
# 4. get the user to choose one of the menu items 
# 5. based on user selection
#  if user selected 'D', ask how much they would like to deposit and update balance
 # if user selected 'W' ask how much they would like to wihtdraw and deduct from balance
#  if the use selected 'B ' show the balance

require 'json'
require 'minitest/autorun'
require 'fileutils' # For more robust file operations if needed, though File.delete is fine

# Constants
ACCOUNTS_FILE_PATH = "accounts.json" # For main application

# Account Class
class Account
  attr_reader :username, :balance

  def initialize(username, balance = 0.0)
    @username = username
    @balance = balance.to_f.round(2)
  end

  def deposit(amount)
    if amount.is_a?(Numeric) && amount > 0
      @balance = (@balance + amount).round(2)
      true
    else
      false
    end
  end

  def withdraw(amount)
    if amount.is_a?(Numeric) && amount > 0 && amount <= @balance
      @balance = (@balance - amount).round(2)
      true
    else
      false
    end
  end
end

# AccountManager Class
class AccountManager
  def initialize(filename)
    @accounts_file = filename
    @accounts = _load_accounts_from_file
  end

  def get_account(username)
    @accounts[username]
  end

  def create_account(username, initial_deposit = 0.0)
    return nil if account_exists?(username) || !valid_amount?(initial_deposit) || initial_deposit < 0

    account = Account.new(username, initial_deposit)
    @accounts[username] = account
    _save_accounts_to_file
    account
  end

  def account_exists?(username)
    @accounts.key?(username)
  end

  def deposit(username, amount)
    account = get_account(username)
    return :account_not_found unless account
    return :invalid_amount unless valid_amount?(amount) && amount > 0

    if account.deposit(amount)
      _save_accounts_to_file
      :success
    else
      :failure # Should be caught by amount > 0 check already
    end
  end

  def withdraw(username, amount)
    account = get_account(username)
    return :account_not_found unless account
    return :invalid_amount unless valid_amount?(amount) && amount > 0

    if amount > account.balance
        return :insufficient_funds
    end

    if account.withdraw(amount)
      _save_accounts_to_file
      :success
    else
      :failure # Should be caught by checks already
    end
  end

  private

  def _load_accounts_from_file
    return {} unless File.exist?(@accounts_file) && !File.zero?(@accounts_file)

    begin
      data = JSON.parse(File.read(@accounts_file))
      data.each_with_object({}) do |(username, balance_data), accs|
        # Assuming balance_data could be a hash { 'balance': value } or just the value
        balance = balance_data.is_a?(Hash) ? balance_data['balance'].to_f : balance_data.to_f
        accs[username] = Account.new(username, balance)
      end
    rescue JSON::ParserError
      {} # Return empty hash if JSON is invalid
    end
  end

  def _save_accounts_to_file
    data_to_save = @accounts.transform_values { |account| account.balance }
    File.open(@accounts_file, 'w') do |file|
      file.write(JSON.pretty_generate(data_to_save))
    end
  end
  
  def valid_amount?(amount)
    amount.is_a?(Numeric)
  end
end

# --- Utility Functions for Input ---
def get_validated_choice(prompt, options)
  loop do
    print prompt
    choice = gets.chomp.upcase # Use upcase for consistency with options array
    return choice if options.include?(choice)
    puts "Invalid choice. Please select from: #{options.join(', ')}."
  end
end

# Parses string input to a float. Returns the float if valid numeric format.
# Returns nil if the format is invalid.
# Positivity is checked by AccountManager or Account class methods.
def parse_numeric_input(input_str)
  begin
    Float(input_str)
  rescue ArgumentError
    nil
  end
end


# --- Main Application Logic (Guarded for Testing) ---
def run_app
  account_manager = AccountManager.new(ACCOUNTS_FILE_PATH)
  current_account = nil

  puts "Welcome to the Coder Bank!"

  # Login/Create Account Loop
  loop do
    prompt_text = "\nDo you want to (L)ogin, (C)reate an account, or (E)xit? "
    choice = get_validated_choice(prompt_text, ['L', 'C', 'E'])

    case choice
    when 'C'
      username = ""
      loop do
        print "Enter a new username: "
        username = gets.chomp
        if username.empty?
          puts "Username cannot be empty. Please try again."
        elsif account_manager.account_exists?(username)
          puts "Username already exists. Please try a different username."
          sub_prompt = "Would you like to (T)ry a different username or (B)ack to main menu? "
          sub_choice = get_validated_choice(sub_prompt, ['T', 'B'])
          break if sub_choice == 'B'
        else
          break
        end
      end
      next if username.empty? || account_manager.account_exists?(username)

      initial_deposit = nil
      loop do
        print "Enter initial deposit amount (must be a non-negative number, e.g., 0 or 50.75): "
        input = gets.chomp
        amount_val = parse_numeric_input(input)

        if amount_val.nil?
          puts "Invalid input format. Please enter a valid number (e.g., 100 or 45.50)."
        elsif amount_val >= 0
          initial_deposit = amount_val
          break
        else
          puts "Initial deposit cannot be negative. Please enter a positive number or zero."
        end
      end

      current_account = account_manager.create_account(username, initial_deposit)
      if current_account
        puts "Account created successfully for #{current_account.username} with a balance of $#{sprintf('%.2f', current_account.balance)}."
        break
      else
        puts "Failed to create account. Please check username and initial deposit validity."
      end
    
    when 'L'
      username = ""
      loop do
        print "Enter your username: "
        username = gets.chomp
        if username.empty?
          puts "Username cannot be empty. Please try again."
        else
          break
        end
      end

      current_account = account_manager.get_account(username)
      if current_account
        puts "Logged in successfully as #{current_account.username}. Your balance is $#{sprintf('%.2f', current_account.balance)}."
        break
      else
        puts "Username not found."
        sub_prompt = "Would you like to (T)ry again, (C)reate a new account, or return to (M)ain menu? "
        sub_choice = get_validated_choice(sub_prompt, ['T', 'C', 'M'])
        next if sub_choice == 'T'
        redo if sub_choice == 'C'
      end
    when 'E'
      puts "Exiting the application. Goodbye!"
      exit
    end
  end

  if current_account.nil?
    puts "No user session started. Exiting."
    exit
  end

  puts "\n--- Main Menu ---"
  loop do
    prompt_text = "\nHello #{current_account.username}, please choose: (D)eposit, (W)ithdraw, (B)alance, (E)xit: "
    user_input = get_validated_choice(prompt_text, ['D', 'W', 'B', 'E'])

    case user_input
    when 'D'
      print "How much would you like to deposit? "
      input = gets.chomp
      amount = parse_numeric_input(input)

      if amount.nil?
        puts "Invalid input format. Please enter a valid number for the amount."
        next
      end

      result = account_manager.deposit(current_account.username, amount)
      case result
      when :success
        puts "Thanks, you have successfully deposited $#{sprintf('%.2f', amount)}. New balance: $#{sprintf('%.2f', current_account.balance)}"
      when :invalid_amount
        puts "Invalid amount. Deposit amount must be greater than zero."
      when :account_not_found
        puts "Error: Account '#{current_account.username}' not found. This should not happen."
      else 
        puts "Deposit failed for an unknown reason."
      end
    when 'W'
      print "How much would you like to withdraw? "
      input = gets.chomp
      amount = parse_numeric_input(input)

      if amount.nil?
        puts "Invalid input format. Please enter a valid number for the amount."
        next
      end

      result = account_manager.withdraw(current_account.username, amount)
      case result
      when :success
        puts "You withdrew $#{sprintf('%.2f', amount)}. New balance: $#{sprintf('%.2f', current_account.balance)}"
      when :insufficient_funds
        puts "Insufficient funds. Your current balance is $#{sprintf('%.2f', current_account.balance)}."
      when :invalid_amount
        puts "Invalid amount. Withdrawal amount must be greater than zero."
      when :account_not_found
        puts "Error: Account '#{current_account.username}' not found. This should not happen."
      else
        puts "Withdrawal failed for an unknown reason."
      end
    when 'B'
      puts "Your balance is $#{sprintf('%.2f', current_account.balance)}"
    when 'E'
      puts "Logging out. Goodbye, #{current_account.username}!"
      break
    end
  end
  puts "\nThanks for visiting the Coder Bank, #{current_account.username}!"
end

# --- Minitest Test Classes ---
class TestAccount < Minitest::Test
  def setup
    @account = Account.new("testuser", 100.00)
  end

  def test_initialize
    assert_equal "testuser", @account.username
    assert_equal 100.00, @account.balance

    account2 = Account.new("user2")
    assert_equal "user2", account2.username
    assert_equal 0.00, account2.balance

    account3 = Account.new("user3", 10.123)
    assert_equal 10.12, account3.balance

    account4 = Account.new("user4", 10.999)
    assert_equal 11.00, account4.balance # Testing rounding up
  end

  def test_deposit_positive
    assert @account.deposit(50.55)
    assert_equal 150.55, @account.balance
  end
  
  def test_deposit_rounding
    @account.deposit(0.005) # Should round up
    assert_equal 100.01, @account.balance # 100 + 0.005 rounds to 100.01

    account2 = Account.new("roundtest", 10.12)
    account2.deposit(0.004) # Should not change significantly for rounding
    assert_equal 10.12, account2.balance
  end

  def test_deposit_zero
    refute @account.deposit(0)
    assert_equal 100.00, @account.balance
  end

  def test_deposit_negative
    refute @account.deposit(-50)
    assert_equal 100.00, @account.balance
  end

  def test_deposit_non_numeric
    refute @account.deposit("abc")
    assert_equal 100.00, @account.balance
  end

  def test_withdraw_valid
    assert @account.withdraw(30.50)
    assert_equal 69.50, @account.balance
  end
  
  def test_withdraw_rounding
    @account.withdraw(0.005) # 100 - 0.005 = 99.995, rounds to 100.00 or 99.99 based on strategy. Ruby's default round half up.
                               # Current implementation: (100 - 0.005).round(2) = 99.995.round(2) = 100.00
    assert_equal 100.00, @account.balance

    account2 = Account.new("roundtest2", 10.12)
    account2.withdraw(0.004) # 10.12 - 0.004 = 10.116.round(2) = 10.12
    assert_equal 10.12, account2.balance
  end

  def test_withdraw_all_funds
    assert @account.withdraw(100.00)
    assert_equal 0.00, @account.balance
  end

  def test_withdraw_insufficient_funds
    refute @account.withdraw(150.00)
    assert_equal 100.00, @account.balance
  end

  def test_withdraw_zero
    refute @account.withdraw(0)
    assert_equal 100.00, @account.balance
  end

  def test_withdraw_negative
    refute @account.withdraw(-50)
    assert_equal 100.00, @account.balance
  end

  def test_withdraw_non_numeric
    refute @account.withdraw("abc")
    assert_equal 100.00, @account.balance
  end
end

class TestAccountManager < Minitest::Test
  TEST_ACCOUNTS_FILE = "test_accounts.json"

  def setup
    File.delete(TEST_ACCOUNTS_FILE) if File.exist?(TEST_ACCOUNTS_FILE)
    @manager = AccountManager.new(TEST_ACCOUNTS_FILE)
  end

  def teardown
    File.delete(TEST_ACCOUNTS_FILE) if File.exist?(TEST_ACCOUNTS_FILE)
  end

  def test_initialize_no_file
    assert_empty @manager.instance_variable_get(:@accounts)
  end

  def test_load_from_valid_file
    # Manually create file
    File.open(TEST_ACCOUNTS_FILE, 'w') do |f|
      f.write(JSON.pretty_generate({ "user1" => 150.75, "user2" => 200.00 }))
    end
    manager2 = AccountManager.new(TEST_ACCOUNTS_FILE)

    assert manager2.account_exists?("user1")
    assert manager2.account_exists?("user2")
    refute manager2.account_exists?("nonexistent")

    acc1 = manager2.get_account("user1")
    assert_instance_of Account, acc1
    assert_equal "user1", acc1.username
    assert_equal 150.75, acc1.balance
  end

  def test_load_from_empty_json_file
    File.open(TEST_ACCOUNTS_FILE, 'w') { |f| f.write("{}") }
    manager2 = AccountManager.new(TEST_ACCOUNTS_FILE)
    assert_empty manager2.instance_variable_get(:@accounts)
  end

  def test_load_from_empty_file_content
    File.open(TEST_ACCOUNTS_FILE, 'w') { |f| f.write("") } # File exists but is empty
    manager2 = AccountManager.new(TEST_ACCOUNTS_FILE)
    assert_empty manager2.instance_variable_get(:@accounts) # Should treat as no accounts
  end

  def test_load_from_invalid_json_file
    File.open(TEST_ACCOUNTS_FILE, 'w') { |f| f.write("this is not json") }
    manager2 = AccountManager.new(TEST_ACCOUNTS_FILE)
    assert_empty manager2.instance_variable_get(:@accounts) # Should handle error and return empty
  end

  def test_create_account_success
    account = @manager.create_account("newuser", 50.0)
    assert_instance_of Account, account
    assert_equal "newuser", account.username
    assert_equal 50.0, account.balance
    assert @manager.account_exists?("newuser")

    # Verify file content
    assert File.exist?(TEST_ACCOUNTS_FILE)
    data = JSON.parse(File.read(TEST_ACCOUNTS_FILE))
    assert_equal ({"newuser" => 50.0}), data
  end

  def test_create_account_existing_username
    @manager.create_account("existing", 100)
    assert_nil @manager.create_account("existing", 50)
  end

  def test_create_account_negative_deposit
    assert_nil @manager.create_account("user_neg_deposit", -50)
  end

  def test_manager_deposit_success
    @manager.create_account("dep_user", 100.0)
    result = @manager.deposit("dep_user", 50.0)
    assert_equal :success, result
    account = @manager.get_account("dep_user")
    assert_equal 150.0, account.balance

    data = JSON.parse(File.read(TEST_ACCOUNTS_FILE))
    assert_equal 150.0, data["dep_user"]
  end

  def test_manager_deposit_non_existent_account
    assert_equal :account_not_found, @manager.deposit("ghost", 50)
  end

  def test_manager_deposit_invalid_amount
    @manager.create_account("dep_user_invalid", 100)
    assert_equal :invalid_amount, @manager.deposit("dep_user_invalid", 0)
    assert_equal :invalid_amount, @manager.deposit("dep_user_invalid", -10)
    # Non-numeric string test is harder here as parse_numeric_input in main script handles it.
    # AccountManager's valid_amount? checks if it's numeric.
    # To test AccountManager directly for non-numeric, one would have to bypass that.
    # For this structure, we assume valid_amount? handles numeric type checks.
  end

  def test_manager_withdraw_success
    @manager.create_account("wd_user", 200.0)
    result = @manager.withdraw("wd_user", 50.0)
    assert_equal :success, result
    account = @manager.get_account("wd_user")
    assert_equal 150.0, account.balance
    data = JSON.parse(File.read(TEST_ACCOUNTS_FILE))
    assert_equal 150.0, data["wd_user"]
  end

  def test_manager_withdraw_non_existent_account
    assert_equal :account_not_found, @manager.withdraw("ghost", 50)
  end

  def test_manager_withdraw_insufficient_funds
    @manager.create_account("wd_user_insufficient", 50)
    assert_equal :insufficient_funds, @manager.withdraw("wd_user_insufficient", 100)
  end

  def test_manager_withdraw_invalid_amount
    @manager.create_account("wd_user_invalid", 100)
    assert_equal :invalid_amount, @manager.withdraw("wd_user_invalid", 0)
    assert_equal :invalid_amount, @manager.withdraw("wd_user_invalid", -10)
  end

  def test_save_and_load_multiple_accounts
    @manager.create_account("multi1", 10)
    @manager.create_account("multi2", 20.22)
    @manager.create_account("multi3", 30.33)

    # Create new manager instance to force reload from file
    manager2 = AccountManager.new(TEST_ACCOUNTS_FILE)
    assert manager2.account_exists?("multi1")
    assert manager2.account_exists?("multi2")
    assert manager2.account_exists?("multi3")
    assert_equal 10, manager2.get_account("multi1").balance
    assert_equal 20.22, manager2.get_account("multi2").balance
    assert_equal 30.33, manager2.get_account("multi3").balance
  end
end

if __FILE__ == $0
  run_app
end