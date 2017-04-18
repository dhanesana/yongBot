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

      def with_artist(m, prefix, sundry, query)
        input_array = query.split(/[[:space:]]/)
        @user_query = input_array.join(' ').downcase
        female_page = Nokogiri::HTML(open("https://kpopinfo114.wordpress.com/female_artist_profiles/"))
        rookie_page = Nokogiri::HTML(open("https://kpopinfo114.wordpress.com/2014-rookie-group-debuts/"))
        @artist_pages = [female_page, rookie_page]
        @artist_hash = Hash.new
        get_artists(m, @artist_pages)
      end

      def get_artists(m, pages)
        pages.each do |page|
          page.css('div.entry-content p').each do |row|
            next if row.text == " "
            next if row.css('a') == []
            next if row.css('a').first == nil
            row_text = row.text
            if row_text.include? '<'
              sliced_text = row_text.slice(0..(row_text.index('<') - 2))
              if row.css('a').first.values[1].to_s.include? "http"
                @artist_hash[sliced_text] = row.css('a').first.values[1]
              else
                @artist_hash[sliced_text] = row.css('a').first.values[0]
              end
            else
              @artist_hash[row_text] = row.css('a').first.values[1]
              if row.css('a').first.values[1].to_s.include? "http"
                @artist_hash[row_text] = row.css('a').first.values[1]
              else
                @artist_hash[row_text] = row.css('a').first.values[0]
              end
            end
          end
        end
        find_match(m)
      end

      def find_match(m)
        artist_match = FuzzyMatch.new(@artist_hash).find(@user_query)
        artist = artist_match.first
        artist_link = artist_match[1]
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
        members.map { |m_name| m_name.slice!('Name (Real Name): ') }
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
