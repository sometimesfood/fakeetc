require_relative 'spec_helper'

require 'fakeetc'

describe FakeEtc do
  before(:each) do
    @groups = {
      'cheeses' => { gid: 10, mem: %w(red_leicester tilsit) },
      'parrots' => { gid: 20, mem: %w(norwegian_blue macaw) }
    }
    @users = {
      'norwegian_blue' => { uid: 10,
                            gid: 20,
                            gecos: 'Remarkable Bird',
                            dir: '/home/parrot',
                            shell: '/bin/zsh' },
      'red_leicester' => { uid: 20,
                           gid: 10,
                           gecos: 'a little Red Leicester',
                           dir: '/home/red_leicester',
                           shell: '/bin/bash' }
    }
    FakeEtc.add_groups(@groups)
    FakeEtc.add_users(@users)
  end

  after(:each) do
    FakeEtc.clear_users
    FakeEtc.endgrent
    FakeEtc.clear_groups
  end

  describe 'activate' do
    it 'should replace Etc with FakeEtc' do
      real_etc = Etc
      fake_etc = FakeEtc
      Etc.must_equal real_etc
      FakeEtc.activate
      Etc.must_equal fake_etc
      FakeEtc.deactivate
      Etc.must_equal real_etc
    end
  end

  describe 'with' do
    it 'should activate Etc in a block' do
      real_etc = Etc
      fake_etc = FakeEtc

      FakeEtc.with do
        Etc.must_equal fake_etc
      end
      Etc.must_equal real_etc
    end
  end

  describe 'without' do
    it 'should activate Etc in a block' do
      real_etc = Etc
      fake_etc = FakeEtc

      FakeEtc.with do
        Etc.must_equal fake_etc
        FakeEtc.without do
          Etc.must_equal real_etc
        end
        Etc.must_equal fake_etc
      end
      Etc.must_equal real_etc
    end
  end

  describe 'getgrnam' do
    it 'should find groups by name' do
      cheese_group = FakeEtc.getgrnam('cheeses')
      cheese_group.must_be_instance_of Struct::Group
      cheese_group.gid.must_equal @groups['cheeses'][:gid]
      cheese_group.mem.must_equal @groups['cheeses'][:mem]
    end

    it 'should raise exceptions for non-existent groups' do
      group_name = 'not-a-group'
      err = -> { FakeEtc.getgrnam(group_name) }.must_raise ArgumentError
      err.message.must_match "can't find group for #{group_name}"
    end
  end

  describe 'getgrgid' do
    it 'should find groups by gid' do
      parrot_group = FakeEtc.getgrgid(@groups['parrots'][:gid])
      parrot_group.must_be_instance_of Struct::Group
      parrot_group.gid.must_equal @groups['parrots'][:gid]
      parrot_group.mem.must_equal @groups['parrots'][:mem]
    end

    it 'should raise exceptions for non-existent groups' do
      gid = 247
      err = -> { FakeEtc.getgrgid(gid) }.must_raise ArgumentError
      err.message.must_match "can't find group for #{gid}"
    end
  end

  describe 'getgrent' do
    it 'should return all group entries in order' do
      cheese_group = FakeEtc.getgrent
      parrot_group = FakeEtc.getgrent
      nil_group = FakeEtc.getgrent

      cheese_group.name.must_equal 'cheeses'
      parrot_group.name.must_equal 'parrots'
      nil_group.must_be_nil
    end
  end

  describe 'endgrent' do
    it 'should reset group traversal' do
      cheese_group_1 = FakeEtc.getgrent
      FakeEtc.endgrent
      cheese_group_2 = FakeEtc.getgrent
      cheese_group_1.must_equal cheese_group_2
      cheese_group_1.name.must_equal 'cheeses'
    end
  end

  describe 'group' do
    it 'should execute a given block for each group entry' do
      groups = {}
      FakeEtc.group { |g| groups[g.name] = { gid: g.gid, mem: g.mem } }
      groups.must_equal @groups
    end

    it 'should behave like getgrent if there was no block given' do
      cheese_group = FakeEtc.group
      parrot_group = FakeEtc.group
      nil_group = FakeEtc.group

      cheese_group.name.must_equal 'cheeses'
      parrot_group.name.must_equal 'parrots'
      nil_group.must_be_nil
    end
  end

  describe 'sysconfdir' do
    it 'should call RealEtc.sysconfdir' do
      FakeEtc.sysconfdir.must_equal RealEtc.sysconfdir
    end
  end

  describe 'systmpdir' do
    it 'should call RealEtc.systmpdir' do
      FakeEtc.systmpdir.must_equal RealEtc.systmpdir
    end
  end

  describe 'getpwnam' do
    it 'should find users by name' do
      red_leicester = FakeEtc.getpwnam('red_leicester')
      red_leicester.must_be_instance_of Struct::Passwd
      red_leicester.uid.must_equal @users['red_leicester'][:uid]
      red_leicester.gid.must_equal @users['red_leicester'][:gid]
      red_leicester.gecos.must_equal @users['red_leicester'][:gecos]
      red_leicester.dir.must_equal @users['red_leicester'][:dir]
      red_leicester.shell.must_equal @users['red_leicester'][:shell]
    end

    it 'should raise exceptions for non-existent users' do
      user_name = 'not-a-user'
      err = -> { FakeEtc.getpwnam(user_name) }.must_raise ArgumentError
      err.message.must_match "can't find user for #{user_name}"
    end
  end
end

describe 'FakeEtc' do
  it 'should activate FakeEtc and run a given block' do
    real_etc = Etc
    fake_etc = FakeEtc

    FakeEtc do
      Etc.must_equal fake_etc
    end
    Etc.must_equal real_etc
  end
end
