require 'genius'

module Cinch
  module Plugins
    class Lyric
      include Cinch::Plugin

      match /(lyric) (.+)/
      match /(genius) (.+)/
      match /(help lyric)$/, method: :help
      match /(help genius)$/, method: :help

      def execute(m, prefix, lyric, keywords)
        Genius.access_token = "#{ENV['RAPGENIUS']}"
        query = keywords.split(/[[:space:]]/).join(' ').downcase
        songs = Genius::Song.search(query)
        return m.reply 'no song found bru' if songs == []
        song_id = songs.first.resource['id']
        song_info = Genius::Song.find(song_id)
        full_title = song_info.raw_response['response']['song']['full_title']
        url = ''
        url = " => #{song_info.media.first['url']}" unless song_info.media == []
        m.reply "#{full_title}#{url}"
      end

      def help(m)
        m.reply 'returns song that includes the specified lyric'
      end

    end
  end
end
