class Bingul
  include Cinch::Plugin

  match /(bingul)$/, prefix: /^(\.)/
  match /(help bingul)$/, method: :help, prefix: /^(\.)/

  def execute(m)
    m.reply "http://www.youtube.com/watch?v=ZQMn_LWz32E"
  end

  def help(m)
    m.reply "sry arrgh .."
  end

end
