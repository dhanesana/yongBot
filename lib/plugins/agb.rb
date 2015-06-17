require 'nokogiri'
require 'open-uri'

class Agb
  include Cinch::Plugin

  match /(agb) (.+)/, prefix: /^(\.)/
  match /(help agb)$/, method: :help, prefix: /^(\.)/

  def execute(m, command, agb, num)
    return m.reply 'greater than 0 bru' if num.to_i < 1
    return m.reply 'less than 21 bru' if num.to_i > 20
    page = Nokogiri::HTML(open('http://www.agbnielsen.co.kr/_hannet/agb/f_rating/rating_01a.asp'))
    date = page.css('span.t_year').text
    station = page.css('div#boardlist td')[3].text if num.to_i == 1
    title = page.css('div#boardlist td')[5] if num.to_i == 1
    title.slice! '<td>'
    title.slice! '</td>'
    return m.reply "AGB Nielson Rank #{num}: #{station} - #{title}" if num.to_i == 1
    x = (num.to_i - 1) * 12
    station = page.css('div#boardlist td')[3 + x].text
    title = page.css('div#boardlist td')[5 + x].text
    title.slice! '<td>'
    title.slice! '</td>'
    m.reply "AGB Nielson Rank #{num}: #{station} - #{title} | #{date}"
  end

  def help(m)
    m.reply 'returns tv show at specified daily agb nielson rank'
  end

end