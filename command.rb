require 'bitcoin-client'
Dir['./coin_config/*.rb'].each {|file| require file }
require './bitcoin_client_extensions.rb'
class Command
  attr_accessor :result, :action, :user_name, :icon_emoji
  ACTIONS = %w(balance deposit tip withdraw commands help disclaimer forum github site invite tipping links network marijuanacoin mar help_balance help_deposit help_tip help_withdraw help_commands help_help help_forum help_github help_site help_invite blocks connections supply hashrate stakeweight help_blocks help_connections help_stakeweight help_supply help_hashrate help_tipping help_links help_network lets_smoke study logos love_you)
    def initialize(slack_params)
    @coin_config_module = Kernel.const_get ENV['COIN'].capitalize
    text = slack_params['text']
    @params = text.split(/\s+/)
    raise "WACK" unless @params.shift == slack_params['trigger_word']
    @user_name = slack_params['user_name']
    @user_id = slack_params['user_id']
    @action = @params.shift
    @result = {}
  end

  def perform
    if ACTIONS.include?(@action)
      self.send("#{@action}".to_sym)
    else
      raise @coin_config_module::PERFORM_ERROR
      @result[:text] = "Type `DabBot help` for more help."
    end
  end

  def client
    @client ||= Bitcoin::Client.local
  end

  def balance
    balance = client.getbalance(@user_id)
    @result[:text] = "<@#{@user_name}>, #{@coin_config_module::BALANCE_REPLY_PRETEXT} #{balance} #{@coin_config_module::CURRENCY_ICON}."
    @result[:icon_emoji] = @coin_config_module::WITHDRAW_ICON
    if balance > @coin_config_module::WEALTHY_UPPER_BOUND
      @result[:text] += @coin_config_module::WEALTHY_UPPER_BOUND_POSTTEXT
      @result[:icon_emoji] = @coin_config_module::WEALTHY_UPPER_BOUND_EMOJI
    elsif balance > 0 && balance < @coin_config_module::WEALTHY_UPPER_BOUND
      @result[:text] += @coin_config_module::BALANCE_REPLY_POSTTEXT
    end

  end

  def deposit
    @result[:text] = "#{@coin_config_module::DEPOSIT_PRETEXT} #{user_address(@user_id)} #{@coin_config_module::DEPOSIT_POSTTEXT}"
    @result[:icon_emoji] = @coin_config_module::WITHDRAW_ICON  
  end

  def tip
    user = @params.shift
    raise @coin_config_module::TIP_ERROR_TEXT unless user =~ /<@(U.+)>/

    target_user = $1
    set_amount

    tx = client.sendfrom @user_id, user_address(target_user), @amount
    @result[:text] = "#{@coin_config_module::TIP_PRETEXT} <@#{@user_id}> --> <@#{target_user}> for #{@amount} #{@coin_config_module::CURRENCY_ICON}."
    @result[:icon_emoji] = @coin_config_module::WITHDRAW_ICON
    @result[:attachments] = [{
      fallback:"<@#{@user_id}> tipped <@#{target_user}> #{@amount}MAR",
      color: "good",
      fields: [{
        title: "See it on the blockchain!",
        value: "http://explorer.marijuanacoin.dabsolutions.co/tx/#{tx}",
        short: false
      }]
    }] 
    
  end

  alias :":marijuanacoin:" :tip

  def withdraw
    address = @params.shift
    set_amount
    tx = client.sendfrom @user_id, address, @amount
    @result[:text] = "#{@coin_config_module::WITHDRAW_TEXT} <@#{@user_id}> => #{address} #{@amount}#{@coin_config_module::CURRENCY_ICON} "
    @result[:text] += " (<#{@coin_config_module::TIP_POSTTEXT1}#{tx}#{@coin_config_module::TIP_POSTTEXT2}>)"
    @result[:icon_emoji] = @coin_config_module::WITHDRAW_ICON
  end

   #def networkinfo
    #info = client.getinfo
    #@result[:text] = info.to_s
    #@result[:icon_emoji] = @coin_config_module::NETWORKINFO_ICON
   #end

  def help
    @result[:text] = "Say `DabBot commands` to learn about all of my commands. `DabBot help_<command>` will give you more info on each command. See https://forum.dabsolutions.co/topic/2/the-dabslack-tipbot for more info."
  end
  
  def commands
    @result[:text] = "I know commands for Tipping, Dab Solutions Links, Marijuanacoin Info and Network stats, and Help. See them all with `DabBot tipping`, `DabBot links`, `DabBot marijuanacoin`, `DabBot network`, and `DabBot help`."
  end
  
  def disclaimer
    @result[:text] = "I, DabBot, as well as Dab Solutions, are not responsible for your Marijuanacoins. Do not use me as your personal MAR wallet. Just keep tipping amounts of MAR in this wallet and the majority of your coins safely in your own control."
  end
  
  # New Commands
  # by xrobesx
  # the bot will be for more than just tipping
  
  
  #command categories
  def tipping
    @result[:text] = "Use me to send tips by using the commands `balance`, `deposit`, `tip`, and `withdraw`."
  end
  
  def links
    @result[:text] = "Use me to access Dab Solutions links with the commands `site`, `forum`, `invite`, and `github`."
  end
  
  def network
    @result[:text] = "I can lookup stats on the Marijuanacoin network. Use `connections`, `blocks`, `supply`, `hashrate`, and `stakeweight`."
  end
  
  def marijuanacoin
    @result[:text] = "I have important links and information for Marijuanacoin. Use `mar site`, `mar btctalk`, `mar cmc`, `mar explorer`, and ``."
  end
  
  
  #links commands
  def site
    @result[:text] = "Here you go, this is our website."
    @result[:attachments] = [{
      color: "good",
      fields: [{
        title: "Dab Solutions",
        value: "http://dabsolutions.co",
        short: false
      }]
    }]
  end
  
  def forum
    @result[:text] = "Anyone is welcome to signup and use our forum."
    @result[:attachments] = [{
      color: "good",
      fields: [{
        title: "DabForum",
        value: "https://forum.dabsolutions.co",
        short: false
      }]
    }]
  end
  
  def github
    @result[:text] = "You'll find me on there, as well as other Dab Solutions projects."
    @result[:icon_emoji] = @coin_config_module::GITHUB_EMOJI
    @result[:attachments] = [{
      color: "good",
      fields: [{
        title: "GitHub - Dab Solutions",
        value: "https://github.com/dabsolutions",
        short: false
      }]
    }]
  end
  
  def invite
    @result[:text] = "Feel free to invite your friends here."
    @result[:attachments] = [{
      color: "good",
      fields: [{
        title: "Slack Invite",
        value: "http://slackinvite.dabsolutions.co",
        short: false
      }]
    }]
  end
  
  
  #network commands 
  def blocks
     info = client.getinfo
     @result[:text] = "I have " + info['blocks'].to_s + " blocks making up the Marijuanacoin blockchain."
     @result[:icon_emoji] = @coin_config_module::NETWORKINFO_ICON
  end

  def connections
     info = client.getinfo
     @result[:text] = "I have " + info['connections'].to_s + " connections to the Marijuanacoin network."
     @result[:icon_emoji] = @coin_config_module::NETWORKINFO_ICON
  end
  
  def stakeweight
     info = client.getmininginfo
     @result[:text] = "The Marijuanacoin network has a network Stake Weight of " + info['netstakeweight'].to_s + "."
     @result[:icon_emoji] = @coin_config_module::NETWORKINFO_ICON
  end
  
  def supply
     info = client.getinfo
     @result[:text] = "There are " + info['moneysupply'].to_s + " marijuanacoins in existence. However a large amount were burned."
     @result[:icon_emoji] = @coin_config_module::NETWORKINFO_ICON
  end
  
  def hashrate
     info = client.getmininginfo
     @result[:text] = "There is " + info['netmhashps'].to_s + " mHash/sec mining on the Marijuanacoin network."
     @result[:icon_emoji] = @coin_config_module::NETWORKINFO_ICON
  end
  
  
  #marijuanacoin commands
  def mar
    word = @params.shift
    if word = site
    	@result[:text] = "Here you go, this is the MAR website." 
    	@result[:attachments] = [{
      		color: "good",
     		fields: [{
        	  title: "Marijuanacoin Site",
        	  value: "http://marijuanacoin.dabsolutions.co",
       	     short: false
      	   }]
    	 }]
    else
    	@result[:text] = "I know `mar site`, `mar explorer`, and `mar btctalk` for now."
    end
    
  end
  
  
  
  
  #random commands
  def lets_smoke
    @result[:text] = "Fuck yea, I'm always down to smoke. Are we smoking dabs or weed?"
  end
  
  def study
    @result[:text] = "I can't learn on my own, someone needs to teach me: https://github.com/dabsolutions/slack_tipbot"
  end
  
  def logos
    @result[:text] = "Official Dab Solutions logos, as well as official logos for our projects can be found here!"
    @result[:attachments] = [{
      color: "good",
      fields: [{
        title: "Official Dab Solutions Logos",
        value: "https://github.com/dabsolutions/official-logos",
        short: false
      }]
    }]
  end
  
  def love_you
    @result[:text] = "I love you too! I love you all."
    @result[:icon_emoji] = @coin_config_module::LOVE_EMOJI
  end
  



  #help commands
  
  #help tipping commands
  def help_balance
    @result[:text] = "Say `DabBot balance` will show you the total number of Marijuanacoins you have in your wallet."
  end
  
  def help_tip
    @result[:text] = "Say `DabBot tip <@user> <amount>` to send someone coins. Replace `<@user>` with a name like @iguanafan and replace `<amount>` with a number like 5."
  end

  def help_deposit
    @result[:text] = "Say `DabBot deposit` for your Marijuanacoin wallet address. You can send MAR to this address to use with me :)"
  end
  
  def help_withdraw
    @result[:text] = "Say `DabBot withdraw address amount` to withdraw coins from this wallet to your own personal wallet. Replace `address` with a MAR address like, MSJYoyFmPYhQxXW2kY3A9DpY7AjcoD2RAu. Also replace `amount` with the amount you're withdrawing."
  end

  #help help/commands
  def help_help
    @result[:text] = "Wow, you really need help..."
  end
  
  def help_commands
    @result[:text] = "Saying 'DabBot commands` shows you all the commands I understand."
  end

  #help links
  def help_site
    @result[:text] = "Say `DabBot site` for the official Dab Solutions site."
  end
  
  def help_invite
    @result[:text] = "Say `DabBot invite` for the official Dab Solutions slack invite page."
  end

  def help_forum
    @result[:text] = "Say `DabBot forum` for the official Dab Solutions Forum link."
  end
  
  def help_github
    @result[:text] = "Say `DabBot github` for the official Dab Solutions Github page."
  end

  #help network 
  def help_blocks
    @result[:text] = "Say `DabBot blocks` for the number of blocks on the MAR blockchain."
  end
  
  def help_connections
    @result[:text] = "Say `DabBot connections` for the number of connects DabBot has to the MAR network."
  end
  
  def help_stakeweight
    @result[:text] = "Say `DabBot stakeweight` for the total weight of coins staking on the MAR network."
  end
  
  def help_supply
    @result[:text] = "Say `DabBot supply` for the total number of Marijuanacoins in existence."
  end 
  
  def help_hashrate
    @result[:text] = "Say `DabBot hashrate` for the total amount of mining power currently on the MAR network."
  end

  #help categories 
  
  def help_tipping
    @result[:text] = "Say `DabBot tipping` to see all of the Tipping commands I know."
  end
  
  def help_links
    @result[:text] = "Say `DabBot links` to see all of the Links commands I know."
  end

  def help_network
    @result[:text] = "Say `DabBot network` to see all of the Network commands I know."
  end
  
  
  # New Commands
  # by xrobesx
  # the bot will be for more than just tipping
  
  

  private

  def set_amount
    amount = @params.shift
    @amount = amount.to_i
    randomize_amount if (@amount == "random")
    
    raise @coin_config_module::TOO_POOR_TEXT unless available_balance >= @amount + 1
    raise @coin_config_module::NO_PURPOSE_LOWER_BOUND_TEXT if @amount < @coin_config_module::NO_PURPOSE_LOWER_BOUND
  end

  def randomize_amount
    lower = [1, @params.shift.to_i].min
    upper = [@params.shift.to_i, available_balance].max
    @amount = rand(lower..upper)
    @result[:icon_emoji] = @coin_config_module::RANDOMIZED_EMOJI
  end

  def available_balance
     client.getbalance(@user_id)
  end

  def user_address(user_id)
     existing = client.getaddressesbyaccount(user_id)
    if (existing.size > 0)
      @address = existing.first
    else
      @address = client.getnewaddress(user_id)
    end
  end


end
