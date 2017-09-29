module Cinch
  module Plugins
    class Help
      include Cinch::Plugin

      match /(help)$/

      def initialize(*args)
        super
        @plugins = [
          ".lineup",
          ".iono",
          ".roll",
          ".rollu",
          ".woll",
          ".gn",
          ".addgn",
          ".sub [subreddit]",
          ".tumblr [user]",
          ".flickr [user]",
          ".nba",
          ".melon [num or title]",
          ".mwave [num]",
          ".cpme",
          ".yomama",
          ".pokemon [name]",
          ".cafe [query]",
          ".naver [num]",
          ".daum [num]",
          ".eat [food_name]",
          ".dispatch",
          ".face [img_url]",
          ".celeb [img_url]",
          ".faceplus [img_url]",
          ".ign [title]",
          ".steam [user]",
          ".sc [keywords]",
          ".wutdis [img_url]",
          ".kst",
          ".buzz",
          ".meet",
          ".meet list",
          ".wshh",
          ".instiz [num/title]",
          ".gaon [num]",
          ".fresh",
          ".agb [num]",
          ".tnms [num]",
          ".lyric [lyrics]",
          ".simply",
          ".asc",
          ".kpoppin",
          ".soundk",
          ".popsinseoul",
          ".superkpop",
          ".csgo [user]",
          ".viki [title]",
          ".now [location]",
          ".trans [words]",
          ".ud [word]",
          ".twins [img_url] [img_url_2]",
          ".sh",
          ".poll [question]",
          ".vote [choice]",
          ".kwikia [term]",
          ".wa [query]",
          ".ebay [query]",
          ".twitch [user]",
          ".kquiz",
          ".genie [num]",
          ".olleh [num]",
          ".mnet [num]",
          ".powerball",
          ".romanize [words]",
          ".github [user]",
          ".nfl",
          ".weekly",
          ".choice [option_1] or [option_2] or ...",
          ".horo [sign]",
          ".zodiac [sign]",
          ".rm",
          ".kmf",
          ".sundry [artist]",
          ".vapp",
          ".beam [user]",
          ".ow [user] [country_abbrev]",
          ".ig [user or #hashtag]",
          ".bugs [num]",
          ".world [num]",
          ".itunes [num]",
          ".dp [news/reviews]",
          ".kb",
          ".arirang",
          ".ruby"
        ]
      end

      def execute(m)
        m.user.msg(@plugins.join(', '))
        m.reply "check ur pms for list of commands bru"
      end

    end
  end
end
