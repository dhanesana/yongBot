class Help
  include Cinch::Plugin

  match /(help)$/, prefix: /^(\.)/

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
      ".cafe [num]",
      ".naver [num]",
      ".daum [num]",
      ".eat [food_name]",
      ".dispatch",
      ".face [img_url]",
      ".vine",
      ".ign [title]",
      ".steam [user]",
      ".sc [keywords]",
      ".celeb [img_url]",
      ".wutdis [img_url]",
      ".[this] or [that]"
    ]
  end

  def execute(m)
    m.reply "=> #{@plugins.join(', ')}"
    m.reply ".help [command] for more info"
  end

end
