module FakeEtc
  def self.add_users(user_hash)
    user_hash.each do |user_name, user_info|
      user = Struct::Passwd.new(user_name,
                                'x',
                                user_info[:uid],
                                user_info[:gid],
                                user_info[:gecos],
                                user_info[:dir],
                                user_info[:shell])
      @users[user_name] = user
    end
  end

  def self.clear_users
    @users = {}
  end

  def self.getpwnam(user_name)
    user = @users[user_name]
    fail ArgumentError, "can't find user for #{user_name}" if user.nil?
    user
  end

  def self.getpwuid(uid)
    user = @users.values.find { |u| u.uid == uid }
    fail ArgumentError, "can't find user for #{uid}" if user.nil?
    user
  end

  def self.getpwent
    @pwents ||= @users.values
    @pwents.shift
  end

  def self.endpwent
    @pwents = nil
  end
  class << self
    alias_method :setpwent, :endpwent
  end

  def self.passwd
    return getpwent unless block_given?
    @users.values.each { |u| yield u }
    endpwent
    nil
  end
end
