# Algorithm/ pseudo code
# 1. display a welcome msg and get the use to input their name 
# 2. retrive the use unput and store it in a veriable for later use
# 3. display hello use name and provide further instruction
# 4. get the user to choose one of the menu items 
# 5. based on user selection
#  if user selected 'D', ask how much they would like to deposit and update balance
 # if user selected 'W' ask how much they would like to wihtdraw and deduct from balance
#  if the use selected 'B ' show the balance

#Flowchart:

puts "Welcome to the Coder Bank, Please enter your name"
name = gets.chomp

puts "hello #{name}, please choose from the options below
D - Deposit
W - Withdraw
B - Show Balance"

user_input = gets.chomp.capitalize
balance = 0
# conditional statement: if else logic to take different path based on weather the condition was evaluated to true


if user_input == 'D'
  puts "How much would you like to deposit?"
  
    input = gets.chomp
    amount = input.to_i
  # converts input to an integer
    if amount > 0
      balance = balance + amount
      puts "Thanks, you have successfull deposited $#{amount}"
    else 
      puts "Invalid amount, please enter value > 0"
    end
elsif user_input == 'W'
  puts "How much would you like to withdraw?"
    input = gets.chomp
    amount = input.to_i
  if amount > 0
      balance = balance - amount
      puts "You withdrew $#{amount}, take the cash"
  else 
    puts "Invalid amount, please enter value > 0"
  end
elsif user_input == 'B'
  puts "Your balance is $#{balance}" 
else 
  puts "Invalid Entry, Try Again"

end

puts "Thanks for visiting the Coder Bank"