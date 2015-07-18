require 'unirest'
require 'open-uri'

class Ud
  include Cinch::Plugin

  match /(ud) (.+)/, prefix: /^(\.)/
  match /(help ud)$/, method: :help, prefix: /^(\.)/

  def execute(m, command, ud, word)
    response = Unirest.get("http://api.urbandictionary.com/v0/define?term=#{URI.encode(word)}")
    return m.reply "no word found bru" if response.body['list'] == []
    definition = response.body['list'].first['definition']
    word_entry = response.body['list'].first['word']
    m.reply "#{word_entry} => #{definition}"
  end

  def help(m)
    m.reply 'returns urbandictionary definition for specified term'
  end

end
