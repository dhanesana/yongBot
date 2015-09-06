require 'nokogiri'
require 'unirest'
require 'open-uri'

class Kquiz
  include Cinch::Plugin

  match /(kquiz)$/, prefix: /^(\.)/
  match /(guess) (.+)/, method: :guess, prefix: /^(\.)/
  match /(help kquiz)$/, method: :help, prefix: /^(\.)/

  def initialize(*args)
    super
    @eng = 0
    @kor = 1
    @all_games = {}
  end

  def execute(m)
    channel = m.channel.name
    if @all_games.keys.include? channel
      m.reply "There's already a game for word: #{@all_games[channel][@kor]}"
    else
      noun_get = Nokogiri::HTML(open("https://www.randomlists.com/nouns"))
      word_count = noun_get.css('span.crux').size - 1
      eng_word = URI.encode(noun_get.css('span.crux')[rand(0..word_count)].text)
      response = Unirest.get("https://www.googleapis.com/language/translate/v2?key=#{ENV['GOOGLE']}&q=#{eng_word}&target=ko")
      kor_word = response.body['data']['translations'].first['translatedText']
      @all_games[channel] = [eng_word, kor_word]
      m.reply "30 seconds to guess! Word is #{kor_word}!"
      m.reply "Type .guess [word] to make your guess"
      game_start(m, kor_word)
    end
  end

  def game_start(m, kor_word)
    channel = m.channel.name
    Timer(15, options = { shots: 1 }) do |x|
      m.reply '15 seconds remaining!' if @all_games[channel][@kor] == kor_word
    end
    Timer(30, options = { shots: 1 }) do |x|
      if @all_games[channel][@kor] == kor_word
        eng_word = @all_games[channel][@eng]
        kor_word = @all_games[channel][@kor]
        @all_games.delete(channel)
        m.reply "Times up! #{kor_word} => #{eng_word}"
      end
    end
  end

  def guess(m, command, guess, words)
    channel = m.channel.name
    user_guess = words.split(/[[:space:]]/).join(' ')
    if @all_games.keys.include? channel
      if @all_games[channel][@eng].downcase == user_guess.downcase
        @all_games.delete(channel)
        m.reply "ding ding ding! good job #{m.user.nick}"
      else
        response = Unirest.get("https://www.googleapis.com/language/translate/v2?key=#{ENV['GOOGLE']}&q=#{user_guess}&target=ko")
        kor_word = response.body['data']['translations'].first['translatedText']
        if kor_word == @all_games[channel][@kor]
          return m.reply "CLOSE... not what I'm looking for though"
        end
        return m.reply "wroong! it's not '#{user_guess}'.." if rand(0..1) == 0
        m.reply "nope.. it's not '#{user_guess}'"
      end
    else
      m.reply "wat u guessing for? type .kquiz to start the quiz"
    end
  end

  def help(m)
    m.reply 'quizzes u on a korean noun. if u cheat, ur cheating urself bru'
  end

end
