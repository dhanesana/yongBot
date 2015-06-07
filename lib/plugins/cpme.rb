require 'rss'

class Cpme
  include Cinch::Plugin

  match /(cpme)$/, prefix: /^(\.)/
  match /(help cpme)$/, method: :help, prefix: /^(\.)/

  def execute(m)
    url = 'https://crayonpop.me/feed/'
    open(url) do |rss|
      feed = RSS::Parser.parse(rss)
      m.reply "#{feed.items.first.title}: #{feed.items.first.link}"
    end
  end

  def help(m)
    m.reply 'returns most recent crayonpop.me post'
  end

end
