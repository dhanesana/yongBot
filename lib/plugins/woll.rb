module Cinch
  module Plugins
    class Woll
      include Cinch::Plugin

      match /(woll)$/
      match /(help woll)$/, method: :help

      def execute(m)
        die_1 = rand(1..6)
        die_2 = rand(1..6)

        k1 = ''
        k1 += '一' if die_1 == 1
        k1 += '二' if die_1 == 2
        k1 += '三' if die_1 == 3
        k1 += '四' if die_1 == 4
        k1 += '五' if die_1 == 5
        k1 += '六' if die_1 == 6

        k2 = ''
        k2 += '一' if die_2 == 1
        k2 += '二' if die_2 == 2
        k2 += '三' if die_2 == 3
        k2 += '四' if die_2 == 4
        k2 += '五' if die_2 == 5
        k2 += '六' if die_2 == 6

        m.reply "[ #{k1} ] [ #{k2} ]"
      end

      def help(m)
        m.reply "is like .roll except more ni hao"
      end

    end
  end
end
