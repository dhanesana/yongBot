class Roll
  include Cinch::Plugin

  match /(roll)$/, prefix: /^(\.)/
  match /(help roll)$/, method: :help, prefix: /^(\.)/

  def initialize(*args)
    super
    @rolls = {}
    @winners = {}
    @active  = 0
    @tie     = 0
  end

  def execute(m)
    if @tie < 1
      return m.reply "u alrdy rolled stupee" if @rolls.keys.include? m.user.nick
      if @active < 1
        @active = 1
        die_2 = rand(1..6)
        die_1 = rand(1..6)
        @rolls[m.user.nick] = die_1 + die_2
        m.reply "15 Seconds! #{m.user.nick}: [ #{die_1} ] [ #{die_2} ]"
        game_start(m)
      else
        die_1 = rand(1..6)
        die_2 = rand(1..6)
        @rolls[m.user.nick] = die_1 + die_2
        m.reply "#{m.user.nick}: [ #{die_1} ] [ #{die_2} ]"
      end
    else
      if @winners.keys.include? m.user.nick
        return m.reply "u alrdy rolled stupee" if @rolls.keys.include? m.user.nick
        die_1 = rand(1..6)
        die_2 = rand(1..6)
        @rolls[m.user.nick] = die_1 + die_2
        m.reply "#{m.user.nick}: [ #{die_1} ] [ #{die_2} ]"
      else
        m.reply "u not in the tiebreak stupee"
      end
    end
  end

  def game_start(m)
    Timer(15, options = { shots: 1 }) do |x|
      @winners = @rolls.select { |k, v| v == @rolls.values.max }
      @rolls = {}
      @active  = 0
      if @winners.size < 2
        m.reply "Winner: #{@winners.keys.join}!"
        @winners = {}
      else
        @tie = 1
        m.reply "Tie break! 15 seconds! GO #{@winners.keys.join(', ')}!"
        tie_break(m)
      end
    end
  end

  def tie_break(m)
    Timer(15, options = { shots: 1 }) do |x|
      @winners = @rolls.select { |k, v| v == @rolls.values.max }
      if @rolls.size < 1
        @tie = 0
        @rolls = {}
        return m.reply 'times up: u all lose'
      end
      @rolls = {}
      if @winners.size < 2
        @tie = 0
        m.reply "Winner: #{@winners.keys.join}!"
        @winners = {}
      else
        @tie = 1
        m.reply "Another Tie! 15 seconds! GO #{@winners.keys.join(', ')}!"
        tie_break(m)
      end
    end
  end

  def help(m)
    m.reply "simple 15-second dice rolling game with tiebreak rounds"
  end

end
