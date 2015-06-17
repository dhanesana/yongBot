require 'open-uri'
require 'json'

class Melon
  include Cinch::Plugin

  match /(melon) (.+)/, prefix: /^(\.)/
  match /(help melon)$/, method: :help, prefix: /^(\.)/

  def execute(m, command, melon, num)
    return m.reply 'invalid num bru' if num.to_i < 1
    link = open("http://www.melon.com/chart/index.htm.json").read
    result = JSON.parse(link)
    rank = result['songList'][num.to_i - 1]['curRank']
    artist = result['songList'][num.to_i - 1]['artistNameBasket']
    song = result['songList'][num.to_i - 1]['songName']
    m.reply "Melon Rank #{rank}: #{artist} - #{song}"
  end

  def help(m)
    m.reply 'returns current song at specified melon rank'
  end

end
