require 'mechanize'
require 'fuzzy_match'

module Cinch
  module Plugins
    class Instiz
      include Cinch::Plugin

      match /(instiz)$/
      match /(ichart)$/
      match /(instiz) (.+)/, method: :with_num
      match /(ichart) (.+)/, method: :with_num
      match /(help instiz)$/, method: :help
      match /(help ichart)$/, method: :help

      def execute(m)
        with_num(m, '.', 'instiz', 1)
      end

      def with_num(m, prefix, instiz, entry)
        return m.reply '1-38 only bru' if entry.to_i > 38
        return m.reply '1-38 only bru' if entry == '0'
        return m.reply '1-38 only bru' if entry.to_i < 0
        agent = Mechanize.new
        referer_url = 'http://ichart.instiz.net/'
        page = agent.get(
            'http://www.instiz.net/iframe_ichart_score.htm',
            nil, referer_url)
        one_song = page.at('div.ichart_score_song1').text
        one_artist = page.at('div.ichart_score_artist1').text
        return m.reply "iChart Rank 1: #{one_song} by #{one_artist}" if entry.to_i == 1
        if !/\A\d+\z/.match(entry)
          with_entry(m, page, one_song, one_artist, entry)
        else
          rank = entry.to_i - 2
          title = page.parser.css('div.ichart_score2_song1')[rank].text
          artist = page.parser.css('div.ichart_score2_artist1')[rank].text
          m.reply "iChart Rank #{entry.to_i}: #{title} by #{artist}"
        end
      end

      def with_entry(m, page, one_song, one_artist, entry)
        all_songs = Hash.new
        all_titles = Array.new
        all_titles << one_song.downcase
        all_songs[1] = one_song
        counter = 2
        page.parser.css('div.ichart_score2_song1').each do |song|
          all_titles << song.text.downcase
          all_songs[counter] = song.text.downcase
          counter += 1
        end
        match = FuzzyMatch.new(all_titles).find(entry.downcase)
        return m.reply "iChart Rank 1: #{one_song} by #{one_artist}" if match == one_song.downcase
        return m.reply "no song found bru" if match.nil?
        match_rank = all_songs.key(match).to_i
        title = page.parser.css('div.ichart_score2_song1')[match_rank - 2].text
        artist = page.parser.css('div.ichart_score2_artist1')[match_rank - 2].text
        m.reply "iChart Rank #{match_rank}: #{title} by #{artist}"
      end

      def help(m)
        m.reply 'returns current song at specified instiz ichart rank'
      end

    end
  end
end
