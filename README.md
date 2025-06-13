# Ruby ATM Application

A Ruby terminal-based ATM application that supports multiple user accounts with persistent balances.

## Features

*   User account creation with an initial deposit.
*   User login for existing accounts.
*   Persistent storage of account data (usernames and balances) in `accounts.json`.
*   Deposit funds into the logged-in user's account.
*   Withdraw funds from the logged-in user's account, including checks for insufficient funds.
*   Check the current account balance.

## How to Run

Simply hit the "Run" button in Replit, or execute `ruby main.rb` in a terminal that has Ruby installed.

## Data File

User account information (usernames and their corresponding balances) is stored in a JSON file named `accounts.json` in the root directory of the application.

## Code Structure

The application's logic is organized using Object-Oriented Principles:
*   `Account`: Represents a single user account, managing its balance and handling deposits and withdrawals for that account.
*   `AccountManager`: Manages the collection of all `Account` objects, including loading them from and saving them to the `accounts.json` file, as well as orchestrating account creation and providing access to account objects.

## Testing

The application includes unit tests for the `Account` and `AccountManager` classes using Ruby's built-in `minitest` library.
The tests are located at the end of the `main.rb` file and will run automatically when the `main.rb` file is executed directly (e.g., via `ruby main.rb`). The main application itself will not run in this scenario due to an `if __FILE__ == $0` guard.

## Installing packages (Replit Specific)

To add packages to your repl, use the Replit packager interface in the left sidebar or using `bundle install` in the shell. Check out the [Bundle docs here](https://bundler.io/guides/getting_started.html).

**Warning: Avoid using `gem install` to add packages.**

Because Ruby repls use [Bundle](https://bundler.io/) under the hood to provide a consistent environment that tracks and installs the exact gems and versions needed, we recommend using `bundle install` instead of `gem install`, which may not work as expected.

## Help (Replit Specific)

If you need help you might be able to find an answer on our [docs](https://docs.replit.com) page. Feel free to report bugs and give us feedback [here](https://replit.com/support).
