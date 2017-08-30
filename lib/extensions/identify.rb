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

  # Ignore banned users (monkey-patch of Message#match)
  def match(regexp, type, strip_colors)
    unless self.user.nil?
      return if $banned.include? self.user.host.downcase
      # Ignore private messages, except those from services or $master
      unless self.user.host == $master || self.user.host.downcase.include?('services')
        return if self.channel? == false
      end
    end
    super
  end
end

module Cinch
  # Prepend module to top-level class Message
  class Message
    prepend YongIdentify
  end
end
