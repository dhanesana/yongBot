module Cinch
  module Plugins
    class Iono
      include Cinch::Plugin

      match /(iono)$/
      match /(help iono)$/, method: :help

      def execute(m)

        yes = [
          "http://i.imgur.com/66VXA2d.gifv",
          "http://i.imgur.com/jx2vBgN.gifv",
          "http://i.imgur.com/jF8ZbQT.gifv",
          "http://i.imgur.com/J976BH7.gifv",
          "http://i.imgur.com/XGFQqN9.gifv"
        ].sample

        no = [
          "http://i.imgur.com/zmqeBGt.gifv",
          "http://i.imgur.com/xVCpmiC.gifv",
          "http://i.imgur.com/9nIwoQy.gifv",
          "http://i.imgur.com/CWlXGRZ.gifv",
          "http://i.imgur.com/40gV6k2.gifv"
        ].sample

        m.reply rand(0..1) == 0 ? yes : no
      end

      def help(m)
        m.reply "returns yes || no"
      end

    end
  end
end
