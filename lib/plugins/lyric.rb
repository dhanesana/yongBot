require 'rapgenius'

module Cinch
  module Plugins
    class Lyric
      include Cinch::Plugin

      match /(lyric) (.+)/
      match /(help lyric)$/, method: :help

      def execute(m, prefix, lyric, keywords)
        query = keywords.split(/[[:space:]]/).join(' ').downcase
        RapGenius::Client.access_token = "#{ENV['RAPGENIUS']}"
        return m.reply 'no song found bru :(' if RapGenius.search_by_lyrics(query) == []
        return m.reply "Corona - Rhythm of the Night https://youtu.be/u3ltZmI5LQw" if query.include? ('nike' && 'reebok')
        song_id = RapGenius.search_by_lyrics(query).first.id
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
  end
end
