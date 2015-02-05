module FakeEtc
  def self.add_groups(group_hash)
    group_hash.each do |group_name, group_info|
      group = Struct::Group.new(group_name,
                                'x',
                                group_info[:gid],
                                group_info[:mem])
      @groups[group_name] = group
    end
  end

  def self.clear_groups
    @groups = {}
  end

  def self.getgrnam(group_name)
    group = @groups[group_name]
    fail ArgumentError, "can't find group for #{group_name}" if group.nil?
    group
  end

  def self.getgrgid(gid)
    group = @groups.values.find { |g| g.gid == gid }
    fail ArgumentError, "can't find group for #{gid}" if group.nil?
    group
  end

  def self.getgrent
    @group_ents ||= @groups.values
    @group_ents.shift
  end

  def self.endgrent
    @group_ents = nil
  end
  class << self
    alias_method :setgrent, :endgrent
  end

  def self.group
    return getgrent unless block_given?

    @groups.values.each do |g|
      yield g
    end
    endgrent
    nil
  end
end
