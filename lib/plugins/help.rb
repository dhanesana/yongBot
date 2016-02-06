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
          ".bingul",
          ".yongpop",
          ".omg",
          ".lovelyz",
          ".ig [tag]",
          ".kmodel",
          ".sub [subreddit]",
          ".tumblr [user]",
          ".flickr [user]",
          ".nba",
          ".melon [num]",
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
          ".faceplus [img_url]",
          ".vine",
          ".ign [title]",
          ".steam [user]",
          ".sc [keywords]",
          ".celeb [img_url]",
          ".wutdis [img_url]",
          ".kst",
          ".buzz",
          ".meet",
          ".meet list",
          ".wshh",
          ".instiz [num]",
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
          ".log",
          ".powerball",
          ".romanize [words]",
          ".github [user]",
          ".nfl",
          ".weekly",
          ".choice [option_1] or [option_2] or ...",
          ".horo [sign]",
          ".zodiac [sign]",
          ".rm",
          ".p101 [rank or name]",
          ".kmf"
        ]
      end

      def execute(m)
        num = @plugins.size.even? ? @plugins.size / 2 : (@plugins.size / 2) + 1
        split_array = @plugins.each_slice(num).to_a
        m.reply "=> #{split_array[0].join(', ')}"
        m.reply "#{split_array[1].join(', ')}"
        m.reply ".help [command] for more info (ie '.help sub')"
      end

    end
  end
end
