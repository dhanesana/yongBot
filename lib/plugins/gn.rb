class Gn
  include Cinch::Plugin

  match /(gn)$/, prefix: /^(\.)/
  match /(help gn)$/, method: :help, prefix: /^(\.)/

  def initialize(*args)
    super
    @gn = [
      "http://i.imgur.com/zseA3sP.jpg",
      "http://i.imgur.com/eT3TWtE.png",
      "http://i.imgur.com/sJuqLKy.gifv",
      "http://i.imgur.com/2qXK47K.jpg",
      "http://i.imgur.com/3Ct6vfM.jpg",
      "http://i.imgur.com/hQ4z6ug.png",
      "http://i.imgur.com/CjnuVw8.png",
      "http://i.imgur.com/T4upJdE.jpg",
      "http://i.imgur.com/XAyCb4z.gifv",
      "http://i.imgur.com/mhvU7fl.jpg",
      "http://i.imgur.com/S3t7SFT.jpg",
      "http://i.imgur.com/M9bmYe7.jpg",
      "http://i.imgur.com/8npvAQi.jpg",
      "http://i.imgur.com/awUeHzO.jpg",
      "http://i.imgur.com/Gw0Xn7X.jpg",
      "http://i.imgur.com/uho9c4M.png",
      "http://i.imgur.com/rCN7cbH.jpg",
      "http://i.imgur.com/V2VIfhJ.jpg",
      "http://i.imgur.com/WQVEyxu.jpg",
      "http://i.imgur.com/ubFCnrw.jpg",
      "http://i.imgur.com/7XHEqqa.jpg"
    ]
  end

  def execute(m)
    m.reply @gn[rand(0..@gn.size - 1)]
  end

  def help(m)
    m.reply "returns random gn pic (#{@gn.size} pics)"
  end

end
