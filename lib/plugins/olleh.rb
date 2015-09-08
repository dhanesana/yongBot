require 'mechanize'

class Olleh
  include Cinch::Plugin

  match /(olleh)$/, prefix: /^(\.)/
  match /(olleh) (.+)/, method: :with_num, prefix: /^(\.)/
  match /(help olleh)$/, method: :help, prefix: /^(\.)/

  def execute(m)
    agent = Mechanize.new
    referer_url = 'http://www.ollehmusic.com/'
    page = agent.get(
      "http://www.ollehmusic.com/Ranking/f_RealTimeRankingList.asp",
      nil,
      referer_url
    )
    num = 1
    title  = page.parser.css('a.titletxt')[num].text
    artist = page.parser.css('p.artist a')[num - 1].text
    date   = page.parser.css('div.time_1').first.text
    time   = page.parser.css('div.cur_time p.current').text
    time.slice!(-1)
    m.reply "Olleh Rank 1: #{artist} - #{title} | #{date} #{time}:00KST"
  end

  def with_num(m, command, olleh, num)
    return m.reply 'invalid num bru' if num.to_i < 1
    return m.reply 'less than 51 bru' if num.to_i > 50
    agent = Mechanize.new
    referer_url = 'http://www.ollehmusic.com/'
    page = agent.get(
      "http://www.ollehmusic.com/Ranking/f_RealTimeRankingList.asp",
      nil,
      referer_url
    )
    title  = page.parser.css('a.titletxt')[num.to_i].text
    artist = page.parser.css('p.artist a')[num.to_i - 1].text
    date   = page.parser.css('div.time_1').first.text
    time   = page.parser.css('div.cur_time p.current').text
    time.slice!(-1)
    m.reply "Olleh Rank #{num}: #{artist} - #{title} | #{date} #{time}:00KST"
  end

  def help(m)
    m.reply 'returns current song at specified olleh music rank'
  end

end
