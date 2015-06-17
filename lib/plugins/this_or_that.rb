class ThisOrThat
  include Cinch::Plugin

  match /([^\s]+) (or) ([^\s]+)$/, prefix: /^(\.)/
  match /(help)\s(this)\s(or)\s(that)/, method: :help, prefix: /^(\.)/

  def execute(m, command, this, orr, that)
    decision = rand(0..1) == 0 ? this : that
    m.reply rand(0..1) < 1 ? "hm.. #{decision}" : "#{decision}!"
  end

  def help(m)
    m.reply "helps you make an otherwise difficult decision"
  end

end
