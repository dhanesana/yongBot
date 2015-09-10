require 'nokogiri'
require 'open-uri'

class Mnet
  include Cinch::Plugin

  match /(mnet)$/, prefix: /^(\.)/
  match /(mnet) (.+)/, method: :with_num, prefix: /^(\.)/
  match /(help mnet)$/, method: :help, prefix: /^(\.)/

  def execute(m)
    num = 1
    page = Nokogiri::HTML(open("http://www.mnet.com/chart/top100/"))
    title = page.css('a.MMLI_Song')[num].text
    artist = page.css('div.MMLITitle_Info')[num].css('a.MMLIInfo_Artist').text
    date = page.css('ul.date li.day span.num_set2').text
    m.reply "Mnet Rank #{num}: #{artist} - #{title} | #{date}"
  end

  def with_num(m, command, mnet, num)
    return m.reply 'invalid num bru' if num.to_i < 1
    return m.reply 'less than 51 bru' if num.to_i > 50
    page = Nokogiri::HTML(open("http://www.mnet.com/chart/top100/"))
    title = page.css('a.MMLI_Song')[num.to_i].text
    artist = page.css('div.MMLITitle_Info')[num.to_i].css('a.MMLIInfo_Artist').text
    date = page.css('ul.date li.day span.num_set2').text
    m.reply "Mnet Rank #{num}: #{artist} - #{title} | #{date}"
  end

  def help(m)
    m.reply 'returns current song at specified mnet rank'
  end

end
