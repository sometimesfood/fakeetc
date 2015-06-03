module FakeEtc # rubocop:disable Documentation
  class << self
    # Adds groups to the FakeEtc group list.
    #
    # @param group_hash [Hash{String=>Hash{Symbol=>Integer,String}}]
    #   the list of groups that should be added
    #
    # @example
    #   FakeEtc.add_groups({
    #     'empty' => { gid: 42, mem: [] },
    #     'anonymous' => { gid: 43, mem: ['johndoe'] }
    #   })
    #
    # @return [void]
    def add_groups(group_hash)
      passwd = 'x'
      group_hash.each do |group_name, group_info|
        group = Struct::Group.new(group_name,
                                  passwd,
                                  group_info[:gid],
                                  group_info[:mem] || [])
        @groups[group_name] = group
      end
    end

    # Clears the group list.
    # @return [void]
    def clear_groups
      @groups = {}
    end

    # Finds a group by its group name.
    # @param group_name [String] the group's name
    # @return [Struct::Group] the group
    # @raise [ArgumentError] if no group with the given name can be
    #   found
    def getgrnam(group_name)
      group = @groups[group_name]
      fail ArgumentError, "can't find group for #{group_name}" if group.nil?
      group
    end

    # Finds a group by its gid. Returns the current user's primary
    #   group if no gid is supplied.
    # @param gid [Integer] the group's gid
    # @return [Struct::Group] the group
    # @raise [ArgumentError] if no group with the given gid can be
    #   found
    def getgrgid(*gid)
      getbyargs(:group, gid)
    end

    # Returns an entry from the group list. Each successive call
    # returns the next entry or `nil` if the end of the list has been
    # reached.
    #
    # To reset scanning the group list, use {endgrent}.
    #
    # @return [Struct::Group] the next entry in the group list
    def getgrent
      @grents ||= @groups.values
      @grents.shift
    end

    # Ends the process of scanning through the group list.
    # @return [void]
    def endgrent
      @grents = nil
    end
    alias_method :setgrent, :endgrent

    # Executes a block for each group entry.
    # @yield [Struct::Group] the group entry
    # @return [void]
    def group
      return getgrent unless block_given?
      @groups.values.each { |g| yield g }
      endgrent
      nil
    end
  end
end
