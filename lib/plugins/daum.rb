require 'nokogiri'
require 'open-uri'

class Daum
  include Cinch::Plugin

  match /(daum)$/, prefix: /^(\.)/
  match /(daum) (.+)/, method: :with_num, prefix: /^(\.)/
  match /(help daum)$/, method: :help, prefix: /^(\.)/

  def execute(m)
    page = Nokogiri::HTML(open('http://www.daum.net/'))
    text = page.css('ol#realTimeSearchWord div div a')[1].text.delete!("\n") # NAME
    url = page.css('ol#realTimeSearchWord a')[1].first[1] # URL
    m.reply "Daum Trending [1]: #{text} #{url}"
  end

  def with_num(m, prefix, daum, num)
    return m.reply 'invalid num bru' if num.to_i < 1
    page = Nokogiri::HTML(open('http://www.daum.net/'))
    text = page.css('ol#realTimeSearchWord div div a')[num.to_i].text.delete!("\n") # NAME
    url = page.css('ol#realTimeSearchWord a')[num.to_i].first[1] # URL
    m.reply "Daum Trending [#{num}]: #{text} #{url}"
  end

  def help(m)
    m.reply 'returns trending daum search result at specified rank'
  end

end
