require 'bitcoin-client'
Dir['./coin_config/*.rb'].each {|file| require file }
require './bitcoin_client_extensions.rb'
class Command
  attr_accessor :result, :action, :user_name, :icon_emoji
  ACTIONS = %w(balance deposit tip withdraw commands help forum github site invite help_balance help_deposit help_tip help_withdraw help_commands help_help help_forum help_github help_site help_invite marinfo)
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
    end
  end

  def client
    @client ||= Bitcoin::Client.local
  end

  def balance
    balance = client.getbalance(@user_id)
    @result[:text] = "@#{@user_name}, #{@coin_config_module::BALANCE_REPLY_PRETEXT} #{balance} #{@coin_config_module::CURRENCY_ICON}."
    if balance > @coin_config_module::WEALTHY_UPPER_BOUND
      @result[:text] += @coin_config_module::WEALTHY_UPPER_BOUND_POSTTEXT
      @result[:icon_emoji] = @coin_config_module::WEALTHY_UPPER_BOUND_EMOJI
    elsif balance > 0 && balance < @coin_config_module::WEALTHY_UPPER_BOUND
      @result[:text] += @coin_config_module::BALANCE_REPLY_POSTTEXT
    end

  end

  def deposit
    @result[:text] = "#{@coin_config_module::DEPOSIT_PRETEXT} #{user_address(@user_id)} #{@coin_config_module::DEPOSIT_POSTTEXT}"
  end

  def tip
    user = @params.shift
    raise @coin_config_module::TIP_ERROR_TEXT unless user =~ /<@(U.+)>/

    target_user = $1
    set_amount

    tx = client.sendfrom @user_id, user_address(target_user), @amount
    @result[:text] = "#{@coin_config_module::TIP_PRETEXT} <@#{@user_id}> --> <@#{target_user}> for #{@amount} #{@coin_config_module::CURRENCY_ICON}"
    @result[:attachments] = [{
      fallback:"<@#{@user_id}> tipped <@#{target_user}> #{@amount}MAR",
      color: "good",
      fields: [{
        title: "See it on the blockchain!",
        value: "http://explorer.marijuanacoin.dabsolutions.co/tx/#{tx}",
        short: false
      }]
    }] 
    
    @result[:text] += " (<#{@coin_config_module::TIP_POSTTEXT1}#{tx}#{@coin_config_module::TIP_POSTTEXT2}>)"
  end

  alias :":dogecoin:" :tip

  def withdraw
    address = @params.shift
    set_amount
    tx = client.sendfrom @user_id, address, @amount
    @result[:text] = "#{@coin_config_module::WITHDRAW_TEXT} <@#{@user_id}> => #{address} #{@amount}#{@coin_config_module::CURRENCY_ICON} "
    @result[:text] += " (<#{@coin_config_module::TIP_POSTTEXT1}#{tx}#{@coin_config_module::TIP_POSTTEXT2}>)"
    @result[:icon_emoji] = @coin_config_module::WITHDRAW_ICON
  end

  # def networkinfo
  #  info = client.getinfo
  #  @result[:text] = info.to_s
  #  @result[:icon_emoji] = @coin_config_module::NETWORKINFO_ICON
  # end

  def help
    @result[:text] = "Type `dabbot commands` for a list of commands. Type `dabbot help_<command>` for more info on each command. See https://forum.dabsolutions.co/topic/2/the-dabslack-tipbot for more info."
  end
  
  # New Commands
  # by xrobesx
  # the bot will be for more than just tipping
  
  def forum
    @result[:text] = "Here's the DabForum -> https://forum.dabsolutions.co"
  end
  
  def github
    @result[:text] = "Dab Solutions Github -> https://github.com/dabsolutions"
  end
  
  def site
    @result[:text] = "Check out our homepage -> http://dabsolutions.co"
  end
  
  def invite
    @result[:text] = "Here you go, invite some friends -> http://slackinvite.dabsolutions.co"
  end
  
  def marinfo
    @result[:text] = "Here you go, invite some friends -> http://slackinvite.dabsolutions.co"
  end

  

  #help commands
  def help_balance
    @result[:text] = "Typing `dabbot balance` will show you the total number of Marijuanacoins you have in your wallet."
  end
  
  def help_tip
    @result[:text] = "Type `dabbot tip <@user> <amount>` to send someone coins. Replace `<@user>` with a name like @iguanafan and replace `<amount>` with a number like 5."
  end

  def help_deposit
    @result[:text] = "Typing `dabbot deposit` will show you your Marijuanacoin wallet address. You can send MAR to this address to use with me :)"
  end
  
  def help_withdraw
    @result[:text] = "Type `dabbot withdraw <address> <amount>` to withdraw coins from this wallet to your own personal wallet. Replace `<address>` with a MAR address like, MSJYoyFmPYhQxXW2kY3A9DpY7AjcoD2RAu. Also replace `<amount>` with the amount you're withdrawing."
  end

  def help_help
    @result[:text] = "Wow, you really need help..."
  end
  
  def help_commands
    @result[:text] = "Typing 'dabbot commands` shows you all the commands I understand."
  end

  def help_site
    @result[:text] = "Type `dabbot site` for the official Dab Solutions site."
  end
  
  def help_invite
    @result[:text] = "Type `dabbot invite` for the official Dab Solutions slack invite page."
  end

  def help_forum
    @result[:text] = "Type `dabbot forum` for the official Dab Solutions Forum link."
  end
  
  def help_github
    @result[:text] = "Type `dabbot github` for the official Dab Solutions Github page."
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

  def commands
    @result[:text] = "I'm not that smart, I know `balance`, `tip`, `deposit`, 'withdraw`, `site`, `invite`, `forum`, `github`, `help` and `help_<command>`."
  end

end
