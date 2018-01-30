# Slack Tipbot

#### coin-agnostic crypto Tipbot for [Slack](http://slackinvite.dabsolutions.co)

## Setup

Get yourself a server (from whever you desire) 

#### Compile your coin

These instructions should be similar for most other coins.

Add the following to your config file, changing the username and password to something secure. Make sure to take note of the `rpcuser` and * `rpcpassword` because you'll need them in a couple of steps
      
      * `daemon=1`
      * `rpcuser=DabSolutions`
      * `rpcpassword=xrobesxandothers`
      * `port=9333`
      * `rpcport=8332`
      * `rpcthreads=100`
      * `irc=0`
      * `dnsseed=1`
 
  * Wait for the blockchain to sync.  (take note the bot looks for rpcport-8332 no matter what coin you're using)

#### Clone the CoinTipper Bot git repo

* `git clone https://github.com/dabsolutions/slack_tipbot.git`
* Install bundler
  * `apt-get install bundler`
* Install Ruby 2.1.1 and rvm
  * `\curl -sSL https://get.rvm.io | bash -s stable --ruby`
  * To start using RVM you need to run `source /usr/local/rvm/scripts/rvm`
* Run `bundle`

#### Set up the Slack integration: as an "outgoing webhook" 

* https://yoursite.slack.com/services/new/outgoing-webhook
* Write down the api token they show you in this page
* Set the trigger word. For this example above we used `tipper`
* Set the Url to the server you'll be deploying on http://example.com:4567/tip

#### Give your bot some attitude!

* Copy `coin_config/litecoin.rb` to a file in `coin_config/` and name it after your coin. 
* Open your newly copied file and change the name of the `module` to the same name as your coin. 
* This file contains all the snippets of text, emojis, and variables needed to customize your bot's behavior and attitude 

#### Launch the server!

* `RPC_USER=DabSolutions RPC_PASSWORD=xrobesxandothers SLACK_API_TOKEN=your_api_key COIN=litecoin bundle exec ruby tipper.rb -p 4567`
  
## Commands

* Tip - send someone coins

  `tipper tip @somebody 100`

* Deposit - put coins in your wallet

  `tipper deposit`

* Withdraw - take coins out of your wallet

  `tipper withdraw LKzHM7rUB2sP1dgVskVFfdSoysnojuw2pX 100`

* Balance - find out how much is in your wallet

  `tipper balance`


## Security

This runs an unencrypted hot wallet on your server. You should not store significant amounts of cryptocoins in this wallet. Withdraw your tips to an offline wallet often. 

Make sure to lock down your server as the TipBot server as the coins stored 

## Credits

This project was originally forked from [dogetip-slack](https://github.com/tenforwardconsulting/dogetip-slack) by [tenforwardconsulting](https://github.com/tenforwardconsulting)
