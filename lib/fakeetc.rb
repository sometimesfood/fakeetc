require 'fakeetc/version'

module FakeEtc
  def self.add_groups(group_hash)
    group_hash.each do |group_name, group_info|
      group = Struct::Group.new(group_name,
                                'x',
                                group_info[:gid],
                                group_info[:mem])
      @groups ||= {}
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
end
