module FakeEtc
  class << self
    def add_groups(group_hash)
      group_hash.each do |group_name, group_info|
        group = Struct::Group.new(group_name,
                                  'x',
                                  group_info[:gid],
                                  group_info[:mem])
        @groups[group_name] = group
      end
    end

    def clear_groups
      @groups = {}
    end

    def getgrnam(group_name)
      group = @groups[group_name]
      fail ArgumentError, "can't find group for #{group_name}" if group.nil?
      group
    end

    def getgrgid(gid)
      group = @groups.values.find { |g| g.gid == gid }
      fail ArgumentError, "can't find group for #{gid}" if group.nil?
      group
    end

    def getgrent
      @grents ||= @groups.values
      @grents.shift
    end

    def endgrent
      @grents = nil
    end
    alias_method :setgrent, :endgrent

    def group
      return getgrent unless block_given?
      @groups.values.each { |g| yield g }
      endgrent
      nil
    end
  end
end
