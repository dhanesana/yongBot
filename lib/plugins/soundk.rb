require 'nokogiri'
require 'open-uri'

class Soundk
  include Cinch::Plugin

  match /(soundk)$/, prefix: /^(\.)/
  match /(help soundk)$/, method: :help, prefix: /^(\.)/

  def execute(m)
    page = Nokogiri::HTML(open('http://www.arirang.co.kr/Radio/Radio_Announce.asp?PROG_CODE=RADR0147&MENU_CODE=101562&code=Be4'))
    lineup = []
    i = 1
    2.times do
      lineup << page.css('td')[i].text unless page.css('td')[i].text[0].to_i == 0
      i += 4
    end
    m.reply "[#{lineup.join('], [')}] 20:00 ~ 22:00KST"
  end

  def help(m)
    m.reply 'returns upcoming schedule for arirang sound k'
  end

end
