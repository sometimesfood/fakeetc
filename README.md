fakeetc
=======

[![Gem Version](http://img.shields.io/gem/v/fakeetc.svg?style=flat-square)][gem]
[![Build Status](http://img.shields.io/travis/sometimesfood/fakeetc.svg?style=flat-square)][travis]
[![Code Climate](http://img.shields.io/codeclimate/github/sometimesfood/fakeetc.svg?style=flat-square)][codeclimate]

A fake Ruby `Etc` module for your tests.

Intended as a drop-in replacement for [Etc][etc] in unit tests.

[etc]: http://ruby-doc.org/stdlib-2.2.0/libdoc/etc/rdoc/Etc.html

Usage
-----

```ruby
require 'fakeetc'

FakeEtc.add_groups({
  'empty' => { gid: 42, mem: [] },
  'anonymous' => { gid: 43, mem: ['johndoe'] }
})
FakeEtc.add_users({
  'janedoe' => { uid: 10,
                 gid: 20,
                 gecos: 'Jane Doe',
                 dir: '/home/janedoe',
                 shell: '/bin/zsh' },
  'jackdoe' => { uid: 50,
                 gid: 60,
                 gecos: 'Jack Doe',
                 dir: '/home/jackdoe',
                 shell: '/bin/bash' },
})

anonymous = nil
jack = nil

FakeEtc do
  anonymous = Etc.getgrnam('anonymous')
  jack = Etc.getpwuid(50)
end

anonymous
# => #<struct Struct::Group
#      name="anonymous",
#      passwd="x",
#      gid=43,
#      mem=["johndoe"]>

jack
# => #<struct Struct::Passwd
#      name="jackdoe",
#      passwd="x",
#      uid=50,
#      gid=60,
#      gecos="Jack Doe",
#      dir="/home/jackdoe",
#      shell="/bin/bash",
#      change=nil,
#      uclass=nil,
#      expire=nil>
```

Copyright
---------

Copyright (c) 2015 Sebastian Boehm. See LICENSE for details.

[gem]: https://rubygems.org/gems/fakeetc
[travis]: https://travis-ci.org/sometimesfood/fakeetc
[codeclimate]: https://codeclimate.com/github/sometimesfood/fakeetc
