require 'soundcloud'

class Sc
  include Cinch::Plugin

  match /(sc) (.+)/, prefix: /^(\.)/
  match /(help sc)$/, method: :help, prefix: /^(\.)/

  def execute(m, command, sc, keyword)
    client = Soundcloud.new(:client_id => ENV['SC_ID'])
    tracks = client.get('/tracks', :q => "#{keyword}")
    return m.reply "'#{keyword}' not found bru" if tracks == []
    url = tracks.first['permalink_url']
    title = tracks.first['title']
    m.reply "#{title} | #{url}"
  end

  def help(m)
    m.reply 'returns first soundcloud result of specified keyword'
  end

end
