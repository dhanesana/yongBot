class Gn
  include Cinch::Plugin

  match /(gn)$/, prefix: /^(\.)/
  match /(help gn)$/, method: :help, prefix: /^(\.)/

  def initialize(*args)
    super
    @gn = [
      "http://i.imgur.com/zseA3sP.jpg",
      "http://i.imgur.com/eT3TWtE.png",
      "http://i.imgur.com/sJuqLKy.gif",
      "http://i.imgur.com/2qXK47K.jpg",
      "http://i.imgur.com/3Ct6vfM.jpg",
      "http://i.imgur.com/hQ4z6ug.png",
      "http://i.imgur.com/CjnuVw8.png",
      "http://i.imgur.com/T4upJdE.jpg"
    ]
  end

  def execute(m)
    m.reply @gn[rand(0..@gn.size - 1)]
  end

  def help(m)
    m.reply "returns random gn pic (#{@gn.size} pics)"
  end

end
