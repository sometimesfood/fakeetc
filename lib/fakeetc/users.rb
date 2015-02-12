module FakeEtc # rubocop:disable Documentation
  class << self
    # Adds users to the FakeEtc user list.
    #
    # @param user_hash [Hash{String=>Hash{Symbol=>Integer,String}}]
    #   the list of users that should be added
    #
    # @example
    #   FakeEtc.add_users({
    #     'janedoe' => { uid: 10,
    #                    gid: 20,
    #                    gecos: 'Jane Doe',
    #                    dir: '/home/janedoe',
    #                    shell: '/bin/zsh' },
    #     'jackdoe' => { uid: 50,
    #                    gid: 60,
    #                    gecos: 'Jack Doe',
    #                    dir: '/home/jackdoe',
    #                    shell: '/bin/bash' },
    #   })
    #
    # @return [void]
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

    # Clears the user list.
    # @return [void]
    def clear_users
      @users = {}
    end

    # Finds a user by their user name.
    # @param user_name [String] the user's name
    # @return [Struct::Passwd] the user
    # @raise [ArgumentError] if no user with the given name can be
    #   found
    def getpwnam(user_name)
      user = @users[user_name]
      fail ArgumentError, "can't find user for #{user_name}" if user.nil?
      user
    end

    # Finds a user by their user id.
    # @param uid [Integer] the user's id
    # @return [Struct::Passwd] the user
    # @raise [ArgumentError] if no user with the given id can be found
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

    # Executes a block for each user entry.
    # @yield [Struct::Passwd] the user entry
    # @return [void]
    def passwd
      return getpwent unless block_given?
      @users.values.each { |u| yield u }
      endpwent
      nil
    end
  end
end
