require 'cinch'

# User checks
module YongIdentify
  # Checks if message is from $master
  def is_admin?
    self.user.host == $master
  end

  # Checks if message is from a channel operator
  def is_op?
    ops = self.channel.ops.map { |usr| usr.host }
    ops.include? self.user.host
  end

  # Response for unauthorized users
  def is_unauthorized
    reply "https://youtu.be/OBWpzvJGTz4"
  end
end

module Cinch
  # Prepend module to top-level class Message
  class Message
    prepend YongIdentify
  end
end
