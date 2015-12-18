module Cinch
  module Plugins
    class Choice
      include Cinch::Plugin

      match /(choice) (.+) (or) (.+)$/
      match /(select) (.+) (or) (.+)$/
      match /(choose) (.+) (or) (.+)$/
      match /(decide) (.+) (or) (.+)$/
      match /(help choice)$/, method: :help
      match /(help select)$/, method: :help
      match /(help choose)$/, method: :help
      match /(help decide)$/, method: :help

      def execute(m, prefix, choice, this, orr, that)
        decision = rand(0..1) == 0 ? this : that
        m.reply rand(0..1) < 1 ? "hm.. #{decision}" : "#{decision}!"
      end

      def help(m)
        m.reply "helps you make an otherwise difficult decision"
      end

    end
  end
end
