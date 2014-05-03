# Slack Tipbot

#### A crypto-coin tipping bot for [Slack](https://slack.com)

## Setup

1. Go to digitalocean.com and create a new droplet
  * hostname: CoinTipper
  * Size
    * I usually go w/ 2GB/2CPUs $20 month
  * Region
    * San Francisco
  * Linux Distributions
    * Ubuntu 14.04 x64
  * Applications
    * Dokku
  * Add SSH keys
2. Copy/Paste IP address into URL bar
  * Put in `hostname`
    * `example.com`
  * Check `Use virtualhost naming for apps
    * `http://<app-name>.example.com`
  * Finish Setup
3. Add DNS
  * Point your domain's nameservers to digitalocean
    * `ns1.digitalocean.com`
    * `ns2.digitalocean.com`
    * `ns3.digitalocean.com`
  * In digitalocean's `DNS` section set an `A-Record` for your `hostname` from your previous step
    * Make the `hostname` be the name of your app
      * `foocointipper`
    * Make the IP address be the one provided by digitalocean for your droplet.
  * After the DNS propogates
    * In the `Zone file` of the DNS section of digital ocean you'll see:
      * `foocointipper	 IN A	143.143.243.143`
    * `ping foocointipper.example.com`
      * `PING foocointipper.example.com (143.143.243.143): 56 data bytes`
4. SSH into your new virualized box
  * `ssh root@ip.address.of.virutalized.box`
    * If you correctly added your SSH keys you'll get signed in
    * Remove root login w/ password
      * `sudo nano /etc/ssh/sshd_config`
        * `PermitRootLogin without-password`
5. Compile your coin
  * Update and install dependencies
    * `apt-get update && apt-get upgrade`
    * `apt-get install ntp git build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev libqrencode-dev`
    * `wget http://miniupnp.free.fr/files/download.php?file=miniupnpc-1.8.tar.gz && tar -zxf download.php\?file\=miniupnpc-1.8.tar.gz && cd miniupnpc-1.8/`
    * `make && make install && cd .. && rm -rf miniupnpc-1.8 download.php\?file\=miniupnpc-1.8.tar.gz`
  * Download the source code
    * `git clone https://github.com/litecoin-project/litecoin`
  * Compile litecoind
    * `cd litecoin/src`
    * `make -f makefile.unix USE_UPNP=1 USE_QRCODE=1 USE_IPV6=1`
    * `strip litecoind`
  * Add a user and move litecoind
    * `adduser litecoin && usermod -g users litecoin && delgroup litecoin && chmod 0701 /home/litecoin`
    * `mkdir /home/litecoin/bin`
    * `cp ~/litecoin/src/litecoind /home/litecoin/bin/litecoind`
    * `chown -R litecoin:users /home/litecoin/bin`
    * `cd && rm -rf litecoin`
  * Run the daemon
    * `su litecoin`
    * `cd && bin/litecoind`    
    * On the first run, litecoind will return an error and tell you to make a configuration file, named litecoin.conf, in order to add a username and password to the file.
      * `nano ~/.litecoin/litecoin.conf && chmod 0600 ~/.litecoin/litecoin.conf`
      * Add the following to your config file, changing the username and password to something secure
        * `daemon=1`
        * `rpcuser=litecoinrpc`
        * `rpcpassword=f0000b4444r`
        * `port=9333`
        * `rpcport=8332`
        * `rpcthreads=100`
        * `irc=0`
        * `dnsseed=1`
    * Run the daemon again
      * `cd && bin/litecoind` 
    * To confirm that the daemon is running
      * `cd && bin/litecoind getinfo`
    * Now wait for the blockchain to sync
6. Clone the CoinTipper Bot git repo
  * `git clone https://github.com/cgcardona/dogetip-slack.git`
  * Install bundler
    * `apt-get install bundler`
  * Install Ruby 2.1.1 and rvm
    * `\curl -sSL https://get.rvm.io | bash -s stable --ruby`
    * To start using RVM you need to run `source /usr/local/rvm/scripts/rvm`
  * Run `bundle`
7. Set up the Slack integration: as an "outgoing webhook" (https://example.slack.com/services/new/outgoing-webhook)
  * Write down the api token they show you in this page
  * Set the trigger word: we use "dogetipper" but doesn't matter what you pick
  * Set the Url to the server you'll be deploying on http://example.com:4567/tip
  * Launch the server!
    * `RPC_USER=litecoinrpc RPC_PASSWORD=your_pass SLACK_API_TOKEN=your_api_key COIN=litecoin bundle exec ruby tipper.rb -p 4569`
  
## Commands

* Tip - send dogecoin!

  `dogetipper tip @somebody 100`
  `dogetipper tip @somebody random`

* Deposit - put dogecoin in

  `dogetipper deposit`

* Withdraw - take dogecoin out

  `dogetipper withdraw DKzHM7rUB2sP1dgVskVFfdSoysnojuw2pX 100`

* Balance - find out how much is in your wallet

  `dogetipper balance`

* Networkinfo - Get the output of getinfo.  Note:  this will disclose the entire aggregate balance of the hot wallet to everyone in the chat

  `dogetipper networkinfo`

## Security

#### This runs an unencrypted hot wallet on your server.  ***This is not even close to secure.***  You should not store significant amounts of dogecoin in this wallet.  Withdraw your tips to an offline wallet often. 

## Credits

This project was originally forked from [dogetip-slack](https://github.com/tenforwardconsulting/dogetip-slack) by [tenforwardconsulting](https://github.com/tenforwardconsulting)