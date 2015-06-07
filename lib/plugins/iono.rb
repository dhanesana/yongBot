class Iono
  include Cinch::Plugin

  match /(iono)$/, prefix: /^(\.)/
  match /(help iono)$/, method: :help, prefix: /^(\.)/

  def execute(m)
    return m.reply "yes" if rand(0..1) == 0
    m.reply "no"
  end

  def help(m)
    m.reply "returns yes || no"
  end

end
