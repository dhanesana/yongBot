require 'mechanize'

class Instiz
  include Cinch::Plugin

  match /(instiz) (.+)/, prefix: /^(\.)/
  match /(help instiz)$/, method: :help, prefix: /^(\.)/

  def execute(m, command, instiz, num)
    agent = Mechanize.new
    referer_url = 'http://ichart.instiz.net/'
    page = agent.get(
        'http://www.instiz.net/iframe_ichart_score.htm',
        nil, referer_url)
    rank = num.to_i - 2
    one_song = page.at('div.ichart_score_song1').text
    one_artist = page.at('div.ichart_score_artist1').text
    return m.reply "iChart Rank 1: #{one_song} by #{one_artist}" if num.to_i == 1
    title = page.parser.css('div.ichart_score2_song1')[rank].text
    artist = page.parser.css('div.ichart_score2_artist1')[rank].text
    m.reply "iChart Rank #{num}: #{title} by #{artist}"
  end

  def help(m)
    m.reply 'returns current song at specified instiz ichart rank'
  end

end
