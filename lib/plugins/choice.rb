module Cinch
  module Plugins
    class Choice
      include Cinch::Plugin

      match /(choice) (.+)$/
      match /(select) (.+)$/
      match /(choose) (.+)$/
      match /(decide) (.+)$/
      match /(help choice)$/, method: :help
      match /(help select)$/, method: :help
      match /(help choose)$/, method: :help
      match /(help decide)$/, method: :help

      def execute(m, prefix, command, choices)
        return m.reply "need more than one choice bru" if choices.split(' or ').size < 2
        decision = choices.split(' or ').sample
        m.reply rand(0..1) < 1 ? "hm.. #{decision}" : "#{decision}!"
      end

      def help(m)
        m.reply "helps you make an otherwise difficult decision"
      end

    end
  end
end
