module Cinch
  module Plugins
    class Gn
      include Cinch::Plugin

      match /(gn)$/
      match /(help gn)$/, method: :help

      def initialize(*args)
        super
        @gn_pairs = {}
        @gn = [
          "https://i.imgur.com/zseA3sP.jpg",
          "https://i.imgur.com/eT3TWtE.png",
          "https://i.imgur.com/sJuqLKy.gifv",
          "https://i.imgur.com/2qXK47K.jpg",
          "https://i.imgur.com/3Ct6vfM.jpg",
          "https://i.imgur.com/hQ4z6ug.png",
          "https://i.imgur.com/CjnuVw8.png",
          "https://i.imgur.com/T4upJdE.jpg",
          "https://i.imgur.com/XAyCb4z.gifv",
          "https://i.imgur.com/mhvU7fl.jpg",
          "https://i.imgur.com/S3t7SFT.jpg",
          "https://i.imgur.com/M9bmYe7.jpg",
          "https://i.imgur.com/8npvAQi.jpg",
          "https://i.imgur.com/awUeHzO.jpg",
          "https://i.imgur.com/Gw0Xn7X.jpg",
          "https://i.imgur.com/uho9c4M.png",
          "https://i.imgur.com/rCN7cbH.jpg",
          "https://i.imgur.com/V2VIfhJ.jpg",
          "https://i.imgur.com/WQVEyxu.jpg",
          "https://i.imgur.com/ubFCnrw.jpg",
          "https://i.imgur.com/7XHEqqa.jpg",
          "https://i.imgur.com/LrgA6VG.jpg",
          "https://i.imgur.com/S1P66fV.gifv",
          "https://i.imgur.com/ow92Wv8.jpg",
          "https://i.imgur.com/6cyvpFE.jpg",
          "https://i.imgur.com/98CPRWN.jpg",
          "https://i.imgur.com/7zxduO7.jpg",
          "https://i.imgur.com/QTrb69y.jpg",
          "https://i.imgur.com/N0lJJj0.jpg",
          "https://i.imgur.com/hbWdKmy.jpg",
          "https://i.imgur.com/06WFZku.jpg",
          "https://i.imgur.com/deCEKeH.jpg",
          "https://i.imgur.com/0HlUkPj.jpg",
          "https://i.imgur.com/vy49uKb.jpg",
          "https://i.imgur.com/tdVbV9f.jpg",
          "https://i.imgur.com/ch8MgXg.jpg",
          "https://i.imgur.com/kXOio8B.jpg",
          "https://i.imgur.com/PfxpFDn.jpg",
          "https://i.imgur.com/jLNfGr8.jpg",
          "https://i.imgur.com/IYvy5Kn.jpg",
          "https://i.imgur.com/0lGGgll.jpg",
          "https://i.imgur.com/oiS3ruk.jpg",
          "https://i.imgur.com/NpIgKu3.jpg",
          "https://i.imgur.com/Xg5c1Tt.gifv",
          "https://i.imgur.com/vezmTTh.jpg",
          "https://i.imgur.com/uXenjEL.gifv"
        ]
      end

      def execute(m)
        if @gn_pairs.keys.include? m.prefix.match(/@(.+)/)[1]
          m.reply "u get wat u deserve: #{@gn_pairs[m.prefix.match(/@(.+)/)[1]]}"
        else
          @gn_pairs[m.prefix.match(/@(.+)/)[1]] = @gn.sample
          m.reply @gn_pairs[m.prefix.match(/@(.+)/)[1]]
          Timer(3600, options = { shots: 1 }) do |x|
            @gn_pairs.delete(m.prefix.match(/@(.+)/)[1])
          end
        end
      end

      def help(m)
        m.reply "returns random gn pic (#{@gn.size} pics)"
      end

    end
  end
end
