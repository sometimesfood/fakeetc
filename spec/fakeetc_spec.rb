require_relative 'spec_helper'

require 'fakeetc'

describe FakeEtc do
  before(:each) do
    @groups = {
      'cheeses' => { gid: 10, mem: ['red_leicester', 'tilsit'] },
      'parrots' => { gid: 20, mem: ['norwegian_blue', 'macaw'] }
    }
    FakeEtc.add_groups(@groups)
  end

  after(:each) do
    FakeEtc.clear_groups
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
      FakeEtc.endgrent
      cheese_group_1.must_equal cheese_group_2
      cheese_group_1.name.must_equal 'cheeses'
    end
  end
end
