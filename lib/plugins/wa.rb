require 'nokogiri'
require 'open-uri'

module Cinch
  module Plugins
    class Wa
      include Cinch::Plugin

      match /(wa) (.+)/
      match /(help wa)$/, method: :help

      def execute(m, prefix, wa, text)
        input_array = text.split(/[[:space:]]/)
        query = input_array.join(' ').downcase
        response = Nokogiri::XML(open("http://api.wolframalpha.com/v2/query?appid=#{ENV['WA_ID']}&input=#{URI.encode(query)}"))
        return m.reply "bad query bru" if response.search('subpod').first.nil?
        interp = response.search('subpod').first.text.strip.gsub("\n", " ")
        answer = response.search('subpod')[1].text.strip.gsub("\n", " ")
        m.reply "#{interp} => #{answer}"
      end

      def help(m)
        m.reply 'Sends a query to wolfram alpha and returns a result'
      end

    end
  end
end
