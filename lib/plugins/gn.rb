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
          "http://i.imgur.com/7XHEqqa.jpg",
          "http://i.imgur.com/LrgA6VG.jpg",
          "http://i.imgur.com/S1P66fV.gifv",
          "http://i.imgur.com/ow92Wv8.jpg",
          "http://i.imgur.com/6cyvpFE.jpg",
          "http://i.imgur.com/98CPRWN.jpg",
          "http://i.imgur.com/7zxduO7.jpg",
          "http://i.imgur.com/QTrb69y.jpg",
          "http://i.imgur.com/N0lJJj0.jpg",
          "http://i.imgur.com/hbWdKmy.jpg",
          "http://i.imgur.com/06WFZku.jpg",
          "http://i.imgur.com/deCEKeH.jpg",
          "http://i.imgur.com/0HlUkPj.jpg",
          "http://i.imgur.com/vy49uKb.jpg",
          "http://i.imgur.com/tdVbV9f.jpg",
          "http://i.imgur.com/ch8MgXg.jpg",
          "http://i.imgur.com/kXOio8B.jpg",
          "http://i.imgur.com/PfxpFDn.jpg",
          "http://i.imgur.com/jLNfGr8.jpg",
          "http://i.imgur.com/IYvy5Kn.jpg",
          "http://i.imgur.com/0lGGgll.jpg",
          "http://i.imgur.com/oiS3ruk.jpg",
          "http://i.imgur.com/NpIgKu3.jpg",
          "http://i.imgur.com/Xg5c1Tt.gifv"
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
