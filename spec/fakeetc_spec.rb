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
    FakeEtc.login = 'norwegian_blue'
  end

  after(:each) do
    FakeEtc.endpwent
    FakeEtc.clear_users
    FakeEtc.endgrent
    FakeEtc.clear_groups
    FakeEtc.login = nil
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
    it 'should activate FakeEtc in a block' do
      real_etc = Etc
      fake_etc = FakeEtc

      FakeEtc.with do
        Etc.must_equal fake_etc
      end
      Etc.must_equal real_etc
    end

    it 'should run the block if FakeEtc is already activated' do
      real_etc = Etc
      fake_etc = FakeEtc

      FakeEtc.with do
        Etc.must_equal fake_etc
        FakeEtc.with do
          Etc.must_equal fake_etc
        end
      end
      Etc.must_equal real_etc
    end
  end

  describe 'without' do
    it 'should deactivate FakeEtc in a block' do
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

    it 'should run the block if FakeEtc is already deactivated' do
      real_etc = Etc
      fake_etc = FakeEtc

      FakeEtc.with do
        Etc.must_equal fake_etc
        FakeEtc.without do
          Etc.must_equal real_etc
          FakeEtc.without do
            Etc.must_equal real_etc
          end
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

    it 'should return the primary group of the current user' do
      FakeEtc.login = 'red_leicester'
      cheese_group = FakeEtc.getgrgid
      cheese_group.must_be_instance_of Struct::Group
      cheese_group.gid.must_equal @groups['cheeses'][:gid]
      cheese_group.mem.must_equal @groups['cheeses'][:mem]
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

  describe 'getpwuid' do
    it 'should find users by uid' do
      norwegian_blue = FakeEtc.getpwuid(@users['norwegian_blue'][:uid])
      norwegian_blue.must_be_instance_of Struct::Passwd
      norwegian_blue.uid.must_equal @users['norwegian_blue'][:uid]
      norwegian_blue.gid.must_equal @users['norwegian_blue'][:gid]
      norwegian_blue.gecos.must_equal @users['norwegian_blue'][:gecos]
      norwegian_blue.dir.must_equal @users['norwegian_blue'][:dir]
      norwegian_blue.shell.must_equal @users['norwegian_blue'][:shell]
    end

    it 'should return the current user' do
      FakeEtc.login = 'red_leicester'
      red_leicester = FakeEtc.getpwuid
      red_leicester.must_be_instance_of Struct::Passwd
      red_leicester.uid.must_equal @users['red_leicester'][:uid]
      red_leicester.gid.must_equal @users['red_leicester'][:gid]
      red_leicester.gecos.must_equal @users['red_leicester'][:gecos]
      red_leicester.dir.must_equal @users['red_leicester'][:dir]
      red_leicester.shell.must_equal @users['red_leicester'][:shell]
    end

    it 'should raise exceptions for non-existent groups' do
      uid = 247
      err = -> { FakeEtc.getpwuid(uid) }.must_raise ArgumentError
      err.message.must_match "can't find user for #{uid}"
    end
  end

  describe 'getpwent' do
    it 'should return all user entries in order' do
      norwegian_blue = FakeEtc.getpwent
      red_leicester = FakeEtc.getpwent
      nil_user = FakeEtc.getpwent

      norwegian_blue.name.must_equal 'norwegian_blue'
      red_leicester.name.must_equal 'red_leicester'
      nil_user.must_be_nil
    end
  end

  describe 'endpwent' do
    it 'should reset user traversal' do
      norwegian_blue_1 = FakeEtc.getpwent
      FakeEtc.endpwent
      norwegian_blue_2 = FakeEtc.getpwent
      norwegian_blue_1.must_equal norwegian_blue_2
      norwegian_blue_1.name.must_equal 'norwegian_blue'
    end
  end

  describe 'passwd' do
    it 'should execute a given block for each group entry' do
      users = {}
      FakeEtc.passwd do |u|
        users[u.name] = { uid: u.uid,
                          gid: u.gid,
                          gecos: u.gecos,
                          dir: u.dir,
                          shell: u.shell }
      end
      users.must_equal @users
    end

    it 'should behave like getpwent if there was no block given' do
      norwegian_blue = FakeEtc.passwd
      red_leicester = FakeEtc.passwd
      nil_user = FakeEtc.passwd

      norwegian_blue.name.must_equal 'norwegian_blue'
      red_leicester.name.must_equal 'red_leicester'
      nil_user.must_be_nil
    end
  end

  describe 'getlogin' do
    it 'should return the name of the current fake user' do
      FakeEtc.getlogin.must_equal 'norwegian_blue'
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
