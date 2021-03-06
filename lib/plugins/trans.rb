require 'unirest'
require 'open-uri'
require 'cgi'

module Cinch
  module Plugins
    class Trans
      include Cinch::Plugin

      match /(trans) (.+)/
      match /(help trans)$/, method: :help

      def execute(m, prefix, trans, sentence)
        string = URI.encode(sentence.split(/[[:space:]]/).join(' '))
        response = Unirest.get("https://www.googleapis.com/language/translate/v2?key=#{ENV['GOOGLE']}&q=#{string}&target=en")
        translated = response.body['data']['translations'].first['translatedText']
        source_lang = response.body['data']['translations'].first['detectedSourceLanguage']
        m.reply "Language: #{source_lang.upcase} => #{CGI.unescape_html(translated).gsub(/"/, '').gsub(/\s+/, ' ')}"
      end

      def help(m)
        m.reply 'returns english-translated text'
      end

    end
  end
end
