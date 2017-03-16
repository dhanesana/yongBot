require 'nokogiri'
require 'unirest'
require 'open-uri'

module Cinch
  module Plugins
    class Kquiz
      include Cinch::Plugin

      match /(kquiz)$/
      listen_to :channel, :method => :guess
      match /(help kquiz)$/, method: :help

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
          kor_word = response.body['data']['translations'].first['translatedText'].strip
          @all_games[channel] = [eng_word, kor_word]
          m.reply "30 seconds to guess! Word is #{kor_word}!"
          game_start(m, kor_word)
        end
      end

      def game_start(m, kor_word)
        Timer(15, options = { shots: 1 }) do |x|
          m.reply '15 seconds remaining!' if @all_games[channel][@kor] == kor_word
        end
        Timer(30, options = { shots: 1 }) do |x|
          channel = m.channel.name
          # if @all_games.keys.include? channel
          if @all_games[channel][@kor] == kor_word
            eng_word = @all_games[channel][@eng]
            kor_word = @all_games[channel][@kor]
            @all_games.delete(channel)
            m.reply "Times up! #{kor_word} => #{eng_word}"
          end
        end
      end

      def guess(m)
        channel = m.channel.name
        words_only = m.message.gsub(/[^0-9a-z ]/i, '')
        user_guess = words_only.split(/[[:space:]]/).join(' ').strip
        if @all_games.keys.include? channel
          if @all_games[channel][@eng].downcase == user_guess.downcase
            m.reply "ding ding ding! word is '#{@all_games[channel][@eng]}'. good job #{m.user.nick}"
            @all_games.delete(channel)
          else
            response = Unirest.get("https://www.googleapis.com/language/translate/v2?key=#{ENV['GOOGLE']}&q=#{URI.encode(user_guess)}&target=ko")
            kor_word = response.body['data']['translations'].first['translatedText'].strip
            if kor_word == @all_games[channel][@kor]
              return m.reply "yes... but '#{user_guess}' isn't quite the word i'm looking for"
            end
          end
        end
      end

      def help(m)
        m.reply 'quizzes u on a korean noun. if u cheat, ur cheating urself bru'
      end

    end
  end
end
