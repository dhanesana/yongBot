require 'nokogiri'
require 'open-uri'

class Kpoppin
  include Cinch::Plugin

  match /(kpoppin)$/, prefix: /^(\.)/
  match /(help kpoppin)$/, method: :help, prefix: /^(\.)/

  def execute(m)
    page = Nokogiri::HTML(open('http://www.arirang.co.kr/Radio/Radio_MessageBoard.asp?PROG_CODE=RADR0143&MENU_CODE=101862&code=Be6'))
    text = page.css('tr.ntce td.subjt')[2].text
    p text[0].to_i
    lineup = []
    page.css('tr.ntce td.subjt').each do |subject|
      lineup << subject.text if subject.text[0].to_i > 0
    end
    m.reply "[#{lineup.reverse.join('], [')}] 12:00 ~ 14:00KST"
  end

  def help(m)
    m.reply 'returns upcoming schedule for arirang k-poppin'
  end

end
