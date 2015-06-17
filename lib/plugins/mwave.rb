require 'open-uri'
require 'json'

class Mwave
  include Cinch::Plugin

  match /(mwave) (.+)/, prefix: /^(\.)/
  match /(help mwave)$/, method: :help, prefix: /^(\.)/

  def execute(m, command, mwave, num)
    return m.reply 'invalid num bru' if num.to_i < 1
    link = open("http://mwave.interest.me/mcountdown/vote/mcdChart.json").read
    result = JSON.parse(link)
    if num.to_i <= 3
      rank = result['top3McountdownCharts'][num.to_i - 1]['RANKING']
      song = result['top3McountdownCharts'][num.to_i - 1]['SONG_NM']
      artist = result['top3McountdownCharts'][num.to_i - 1]['artistInfos'].first['ARTIST_NM']
      m.reply "Mwave Rank #{rank}: #{artist} - #{song}"
    else
      rank = result['othersMcountdownCharts'][num.to_i - 4]['RANKING']
      song = result['othersMcountdownCharts'][num.to_i - 4]['SONG_NM']
      artist = result['othersMcountdownCharts'][num.to_i - 4]['artistInfos'].first['ARTIST_NM']
      m.reply "Mwave Rank #{rank}: #{artist} - #{song}"
    end
  end

  def help(m)
    m.reply 'returns current song at specified mwave rank'
  end

end
