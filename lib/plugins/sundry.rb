require 'nokogiri'
require 'open-uri'
require 'fuzzy_match'
require 'date'

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
        match = FuzzyMatch.new(idol_hash).find(artist)
        artist = match.first
        artist_link = match[1]
        artist_page = Nokogiri::HTML(open(artist_link))
        debut = artist_page.css('div.entry-content ul').first.css('li').first.text
        debut.slice!('Debut (Y.M.D): ')
        img_url = ' '
        if artist_page.css('div.entry-content img.aligncenter').size > 0
          img_url += artist_page.css('div.entry-content img.aligncenter').first.attr('src')
          img_url = img_url.slice(0..(img_url.index('?') - 1))
        end
        members = []
        artist_page.css('div.entry-content li').each do |row|
          members << row.text if row.text.include? "Real Name"
        end
        members.map { |name| name.slice!('Name (Real Name): ') }
        if debut.include? '–'
          debut.gsub!('–','??')
          debut.gsub!('.','-')
          m.reply "#{artist} => Debut #{debut} :: Member(s) => #{members.join(', ')}#{img_url}"
        else
          debut_date = Date.parse(debut)
          m.reply "#{artist} => Debut #{debut_date.strftime("%Y-%m-%d")} :: Member(s) => #{members.join(', ')}#{img_url}"
        end
      end

      def help(m)
        m.reply 'searches for debut and member info for specified kpop sundry artist/group'
      end

    end
  end
end
