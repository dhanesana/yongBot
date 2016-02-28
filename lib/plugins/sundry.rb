require 'nokogiri'
require 'open-uri'
require 'date'
require 'fuzzystringmatch'

module Cinch
  module Plugins
    class Sundry
      include Cinch::Plugin

      match /(sundry) (.+)/, method: :with_artist
      match /(help sundry)$/, method: :help

      def with_artist(m, prefix, sundry, name)
        input_array = name.split(/[[:space:]]/)
        artist = input_array.join(' ').downcase
        page = Nokogiri::HTML(open("https://kpopinfo114.wordpress.com/female_artist_profiles/"))
        idol_hash = Hash.new
        page.css('div.entry-content p').each do |row|
          row_text = row.text
          if row_text.include? '<'
            sliced_text = row_text.slice(0..(row_text.index('<') - 2))
            if row.css('a').first.values[1].to_s.include? "http"
              idol_hash[sliced_text] = row.css('a').first.values[1]
            else
              idol_hash[sliced_text] = row.css('a').first.values[0]
            end
          else
            idol_hash[row_text] = row.css('a').first.values[1]
            if row.css('a').first.values[1].to_s.include? "http"
              idol_hash[row_text] = row.css('a').first.values[1]
            else
              idol_hash[row_text] = row.css('a').first.values[0]
            end
          end
        end
        jarow = FuzzyStringMatch::JaroWinkler.create( :pure )
        jarow_matches = Hash.new
        idol_hash.keys.each do |key|
          jarow_matches[key] = jarow.getDistance(artist, key.downcase)
        end
        match = jarow_matches.max_by{ |k, v| v }
        artist = match.first
        idol_link = idol_hash[artist]
        artist_page = Nokogiri::HTML(open(idol_link))
        debut = artist_page.css('div.entry-content ul').first.css('li').first.text
        debut.slice!('Debut (Y.M.D): ')
        debut_date = Date.parse(debut)
        members = []
        artist_page.css('div.entry-content li').each do |row|
          members << row.text if row.text.include? "Real Name"
        end
        members.map { |name| name.slice!('Name (Real Name): ') }
        m.reply "#{artist} => Debut #{debut_date.strftime("%Y-%m-%d")} :: Members => #{members.join(', ')}"
      end

      def help(m)
        m.reply 'returns debut and member info for specified kpop sundry artist/group'
      end

    end
  end
end
