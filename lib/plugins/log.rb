class Log
  include Cinch::Plugin

  match /(log)$/, prefix: /^(\.)/
  listen_to :channel, :method => :log_msg
  match /(help log)$/, method: :help, prefix: /^(\.)/

  def initialize(*args)
    super
    @all_chans = {}
    @nicks = []
    @triggers = 0
  end

  def execute(m)
    return if m.channel.nil?
    return m.reply 'wait bru (5 minutes)' if @nicks.include? m.user.nick
    return m.reply 'wait bru (1 minute)' if @triggers > 2
    # 3 calls per minute
    @triggers += 1
    Timer(60, options = {shots: 1}) do |x|
      @triggers = 0
    end
    # 1 call every 5 minutes per user
    @nicks << m.user.nick
    Timer(300, options = {shots: 1}) do |x|
      @nicks.delete(m.user.nick)
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
    return if m.message == '.log'
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
