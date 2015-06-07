class ThisOrThat
  include Cinch::Plugin

  match /(.+) (or) (.+)$/, prefix: /^(\.)/

  def execute(m, command, this, orr, that)
    puts '*' * 50
    # this[.0] = ''
    p this
    puts '#' * 50
    p that
    return m.reply "hm.. #{this}" if rand(0..1) == 0
    m.reply "=> #{that} <="
  end

end
