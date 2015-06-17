require 'rapgenius'

class Lyric
  include Cinch::Plugin

  match /(lyric) (.+)/, prefix: /^(\.)/
  match /(help lyric)$/, method: :help, prefix: /^(\.)/

  def execute(m, command, lyric, keywords)
    RapGenius::Client.access_token = "#{ENV['RAPGENIUS']}"
    return m.reply 'no song found :(' if RapGenius.search_by_lyrics(lyric) == []
    song_id = RapGenius.search_by_lyrics(keywords).first.id
    song = RapGenius::Song.find(song_id)
    title = song.title
    artist = song.artist.name
    media = ''
    media = song.media.first.url unless song.media.first == nil
    m.reply "#{artist} - #{title} #{media}"
  end

  def help(m)
    m.reply 'returns song that includes the specified lyric'
  end

end
