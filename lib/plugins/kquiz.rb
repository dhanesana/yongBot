require 'nokogiri'
require 'unirest'
require 'open-uri'
require 'json'

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
          # Use Merriam Webster dictionary API for hint
          meaning = ""
          dict_api = Nokogiri::HTML(open("http://www.dictionaryapi.com/api/v1/references/collegiate/xml/#{eng_word}?key=#{ENV['DICT_KEY']}"))
          if dict_api.xpath("//dt").first.nil?
            meaning += "Definition not found."
          else
            meaning += dict_api.xpath("//dt").first.text[1..-1].capitalize
          end
          # Get Korean translated word
          response = Unirest.get("https://www.googleapis.com/language/translate/v2?key=#{ENV['GOOGLE']}&q=#{eng_word}&target=ko")
          kor_word = response.body['data']['translations'].first['translatedText'].strip
          @all_games[channel] = [eng_word, kor_word]
          m.reply "#{num.to_i} seconds to guess#{'(answer includes a hyphen)' if eng_word.include? '-'}! Word is #{kor_word}!"
          game_start(m, kor_word, meaning, num.to_i)
        end
      end

      def game_start(m, kor_word, meaning, num)
        channel = m.channel.name
        if num.to_i > 20
          Timer(15, options = { shots: 1 }) do |x|
            m.reply "15 seconds remaining! Hint: #{meaning}" if @all_games[channel][@kor] == kor_word
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
        return unless @all_games.keys.include? m.channel.name
        channel = m.channel.name
        words_only = m.message.gsub(/[^0-9a-z ]/i, '')
        guess_words = []
        user_guess = words_only.split(/[[:space:]]/).join(' ').strip
        guess_words << user_guess
        # Get singular and plural of user_guess
        get_singular = Nokogiri::HTML(open("http://www.wordhippo.com/what-is/the-singular-of/#{user_guess}.html"))
        if get_singular.css('div.relatedwords b').first != nil
          guess_words << get_singular.css('div.relatedwords b').first.text.strip
        end
        get_plural = Nokogiri::HTML(open("http://www.wordhippo.com/what-is/the-plural-of/#{user_guess}.html"))
        if get_plural.css('div.relatedwords b').first != nil
          guess_words << get_plural.css('div.relatedwords b').first.text.strip
        end
        # Check word, its singular, and its plural form
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
