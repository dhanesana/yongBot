require 'cinch'

module Cinch
  class Message

    def is_admin?
      self.user.host == $master
    end

    def is_op?
      ops = self.channel.ops.map { |usr| usr.host }
      ops.include? self.user.host
    end

  end
end
