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

  class << self
    [:endpwent,
     :getpwent,
     :passwd,
     :setpwent].each do |m|
      define_method(m) do
        fail NotImplementedError, "FakeEtc.#{m} not implemented yet"
      end
    end
  end
end
