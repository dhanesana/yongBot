require 'nokogiri'
require 'unirest'
require 'open-uri'

module Cinch
  module Plugins
    class Kquiz
      include Cinch::Plugin

      match /(kquiz)$/
      match /(kquiz) (.+)/, method: :with_num
      listen_to :channel, :method => :guess
      match /(help kquiz)$/, method: :help

      def initialize(*args)
        super
        @eng = 0
        @kor = 1
        @all_games = {}
      end

      def execute(m)
        with_num(m, '.', 'with_num', 30)
      end

      def with_num(m, prefix, with_num, num)
        return m.is_unauthorized if $banned.include? m.user.host
        return m.reply 'invalid num bru' if num.to_i < 1
        return m.reply 'less than 120 sec bru' if num.to_i > 120
        return m.reply 'at least 30 sec bru' if num.to_i < 30
        channel = m.channel.name
        if @all_games.keys.include? channel
          m.reply "There's already a game for word: #{@all_games[channel][@kor]}"
        else
          noun_get = Nokogiri::HTML(open("http://www.desiquintans.com/noungenerator?count=1"))
          eng_word = noun_get.css('ol').text.strip
          return m.reply 'HTML UPDATE! pls inform botmaster thx' if eng_word.size < 1
          response = Unirest.get("https://www.googleapis.com/language/translate/v2?key=#{ENV['GOOGLE']}&q=#{eng_word}&target=ko")
          kor_word = response.body['data']['translations'].first['translatedText'].strip
          @all_games[channel] = [eng_word, kor_word]
          m.reply "#{num.to_i} seconds to guess! Word is #{kor_word}!"
          game_start(m, kor_word, num.to_i)
        end
      end

      def game_start(m, kor_word, num)
        channel = m.channel.name
        if num.to_i > 20
          Timer(15, options = { shots: 1 }) do |x|
            m.reply '15 seconds remaining!' if @all_games[channel][@kor] == kor_word
          end
        end
        Timer(num.to_i, options = { shots: 1 }) do |x|
          if @all_games[channel][@kor] == kor_word
            eng_word = @all_games[channel][@eng]
            kor_word = @all_games[channel][@kor]
            @all_games.delete(channel)
            m.reply "Time's up! #{kor_word} => #{eng_word}"
          end
        end
      end

      def guess(m)
        return if $banned.include? m.user.host
        return unless @all_games.keys.include? m.channel.name
        channel = m.channel.name
        words_only = m.message.gsub(/[^0-9a-z ]/i, '')
        guess_words = []
        user_guess = words_only.split(/[[:space:]]/).join(' ').strip
        guess_words << user_guess
        # Get singular of user_guess
        page = Nokogiri::HTML(open("http://www.wordhippo.com/what-is/the-singular-of/#{user_guess}.html"))
        if page.css('div.relatedwords b').first != nil
          guess_words << page.css('div.relatedwords b').first.text.strip
        end
        # Check word and singular form
        count = 0
        guess_words.each do |word|
          if @all_games.keys.include? channel
            if @all_games[channel][@eng].downcase == word.downcase
              m.reply "ding ding ding! word is '#{@all_games[channel][@eng]}'. good job #{m.user.nick}"
              return @all_games.delete(channel)
            end
          end
        end
        # Check synonyms
        response = Unirest.get("https://www.googleapis.com/language/translate/v2?key=#{ENV['GOOGLE']}&q=#{URI.encode(user_guess)}&target=ko")
        kor_word = response.body['data']['translations'].first['translatedText'].strip
        if kor_word == @all_games[channel][@kor]
          m.reply "yes... but '#{user_guess}' isn't quite the word i'm looking for"
        end
      end

      def help(m)
        m.reply 'quizzes u on a korean noun. if u cheat, ur cheating urself'
      end

    end
  end
end
