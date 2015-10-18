require 'unirest'
require 'open-uri'

module Cinch
  module Plugins
    class Ud
      include Cinch::Plugin

      match /(ud) (.+)/
      match /(help ud)$/, method: :help

      def execute(m, prefix, ud, keywords)
        query = keywords.split(/[[:space:]]/).join(' ').downcase
        response = Unirest.get("http://api.urbandictionary.com/v0/define?term=#{URI.encode(query)}")
        return m.reply "no word found bru" if response.body['list'] == []
        definition = response.body['list'].first['definition']
        word_entry = response.body['list'].first['word']
        m.reply "#{word_entry} => #{definition}"
      end

      def help(m)
        m.reply 'returns urbandictionary definition for specified term'
      end

    end
  end
end
