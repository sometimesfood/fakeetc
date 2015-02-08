module FakeEtc # rubocop:disable Documentation
  class << self
    def add_users(user_hash)
      passwd = 'x'

      user_hash.each do |user_name, user_info|
        user = Struct::Passwd.new(user_name,
                                  passwd,
                                  user_info[:uid],
                                  user_info[:gid],
                                  user_info[:gecos],
                                  user_info[:dir],
                                  user_info[:shell])
        @users[user_name] = user
      end
    end

    def clear_users
      @users = {}
    end

    def getpwnam(user_name)
      user = @users[user_name]
      fail ArgumentError, "can't find user for #{user_name}" if user.nil?
      user
    end

    def getpwuid(uid)
      user = @users.values.find { |u| u.uid == uid }
      fail ArgumentError, "can't find user for #{uid}" if user.nil?
      user
    end

    def getpwent
      @pwents ||= @users.values
      @pwents.shift
    end

    def endpwent
      @pwents = nil
    end
    alias_method :setpwent, :endpwent

    def passwd
      return getpwent unless block_given?
      @users.values.each { |u| yield u }
      endpwent
      nil
    end
  end
end
