require 'nokogiri'
require 'open-uri'

class Tnms
  include Cinch::Plugin

  match /(tnms) (.+)/, prefix: /^(\.)/
  match /(help tnms)$/, method: :help, prefix: /^(\.)/

  def execute(m, command, tnms, num)
    return m.reply 'invalid num bru' if num.to_i < 1
    return m.reply 'less than 21 bru' if num.to_i > 20
    rank = num.to_i - 1
    page = Nokogiri::HTML(open('http://www.tnms.tv/rating/default.asp'))
    station = page.css('tr.margin2')[rank].css('td')[2].text
    title = page.css('tr.margin2')[rank].css('td')[1].text[0...-3]
    m.reply "TNmS Rank #{num}: #{station} - #{title}"
  end

  def help(m)
    m.reply 'returns tv show at specified daily tnms rank'
  end

end