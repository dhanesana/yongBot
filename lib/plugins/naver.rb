require 'nokogiri'
require 'open-uri'

class Naver
  include Cinch::Plugin

  match /(naver)$/, prefix: /^(\.)/
  match /(naver) (.+)/, method: :with_num, prefix: /^(\.)/
  match /(help naver)$/, method: :help, prefix: /^(\.)/

  def execute(m)
    page = Nokogiri::HTML(open("http://www.naver.com/"))
    text = page.css('ol#realrank li a')[0].children.first.text
    url = page.css('ol#realrank a')[0].first.last
    m.reply "Naver Trending [1]: #{text} #{url}"
  end

  def with_num(m, prefix, naver, num)
    return m.reply 'invalid num bru' if num.to_i < 1
    page = Nokogiri::HTML(open("http://www.naver.com/"))
    text = page.css('ol#realrank li a')[num.to_i - 1].children.first.text
    url = page.css('ol#realrank a')[num.to_i - 1].first.last
    m.reply "Naver Trending [#{num}]: #{text} #{url}"
  end

  def help(m)
    m.reply 'returns trending naver search result at specified rank'
  end

end
