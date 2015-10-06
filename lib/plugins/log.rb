class Log
  include Cinch::Plugin

  match /(log)$/, prefix: /^(\.)/
  listen_to :channel, :method => :log_msg
  match /(help log)$/, method: :help, prefix: /^(\.)/

  def initialize(*args)
    super
    @all_chans = {}
    @user_addrs = []
    @triggers = 0
  end

  def execute(m)
    # get user address from prefix
    user_address = m.prefix.match(/@(.+)/)[1]
    # don't accept pms
    return if m.channel.nil?
    return m.reply 'wait bru (5 minutes)' if @user_addrs.include? user_address
    return m.reply 'wait bru (1 minute)' if @triggers > 2
    # 3 calls per minute
    @triggers += 1
    Timer(60, options = { shots: 1 }) do |x|
      @triggers = 0
    end
    # 1 call every 5 minutes per user
    @user_addrs << user_address
    Timer(300, options = { shots: 1 }) do |x|
      @user_addrs.delete(user_address)
    end
    channel = m.channel.name
    chan_msgs = @all_chans[channel]
    m.reply "#{m.user.nick}: check ur pms"
    chan_msgs.each do |msg|
      User(m.user.nick).send "[#{msg[0]}] #{msg[1]}: #{msg[2]}"
    end
  end

  def log_msg(m)
    return if m.channel.nil?
    # don't log commands
    return if m.message[0] == '.' && m.message[1] != '.'
    return if m.message[0] == '!' && m.message[1] != '.'
    channel = m.channel.name
    time = m.time.utc.strftime("%H:%M:%S %Z")
    user = m.user.nick
    message = m.message
    if @all_chans.keys.include? channel
      chan_msgs = @all_chans[channel]
      # Max 4 messages per channel log
      chan_msgs.shift if chan_msgs.size > 3
      chan_msgs << [time, user, message]
    else
      @all_chans[channel] = []
      @all_chans[channel] << [time, user, message]
    end
  end

  def help(m)
    m.reply 'messages user the previous 4 channel messages'
  end

end
