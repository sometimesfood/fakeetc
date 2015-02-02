fakeetc
=======

A fake Ruby `Etc` module for your tests.

Intended as a drop-in replacement for [Etc][etc] in unit tests.

[etc]: http://ruby-doc.org/stdlib-2.2.0/libdoc/etc/rdoc/Etc.html

Usage
-----

```ruby
require 'fakeetc'

FakeEtc.add_groups({
  'foo' => { gid: 42, mem: [] },
  'bar' => { gid: 43, mem: ['johndoe'] }
})
FakeEtc do
  Etc.getgrnam('bar')
end
# => #<struct Struct::Group name="bar", passwd="x", gid=43, mem=["johndoe"]>
```

Copyright
---------

Copyright (c) 2015 Sebastian Boehm. See LICENSE for details.
