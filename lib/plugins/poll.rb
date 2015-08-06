class Poll
  include Cinch::Plugin

  match /(poll) (.+)/, prefix: /^(\.)/
  match /(vote) (.+)/, method: :vote, prefix: /^(\.)/
  match /(help poll)$/, method: :help_poll, prefix: /^(\.)/
  match /(help vote)$/, method: :help_vote, prefix: /^(\.)/

  def initialize(*args)
    super
    @results = {}
    @active = 0
  end

  def execute(m, command, poll, question)
    return m.reply 'wait stupee' if @active == 1
    @results = {}
    le_question = question
    m.reply "90 Second Poll: #{question}"
    m.reply 'type .vote [choice] to cast your vote!'
    @active = 1
    Timer(75, options = {shots: 1}) do |x|
      m.reply '15 seconds remaining!'
    end
    Timer(90, options = {shots: 1}) do |x|
      @active = 0
      m.reply "TIME'S UP"
      results = []
      @results.each { |k, v| results << k if v.size == @results.values.max.size }
      return m.reply "Winner: #{@results.first.first}!" if results.size < 2
      m.reply "We have a tie: #{results.join(', ')}"
    end
  end

  def vote(m, command, vote, choice)
    return m.reply 'no active poll stupee' if @active == 0
    @results.values.each { |v| return m.reply "u alrdy voted #{m.user.nick.downcase}!" if v.include? m.user.nick }
    if @results[choice.downcase].nil?
      @results[choice.downcase] = [m.user.nick]
    else
      @results[choice.downcase] << m.user.nick
    end
    m.reply "#{m.user.nick} voted"
  end

  def help_poll(m)
    m.reply "creates a new 90 second poll"
  end

  def help_vote(m)
    m.reply "allows you to vote on an active poll"
  end

end
