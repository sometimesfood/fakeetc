# Most functions in this file are based on those in Chris Wanstrath's
# excellent fakefs library (lib/fakefs/base.rb).
#
# The following is a verbatim copy of the original license:
#
#   Copyright (c) 2009 Chris Wanstrath
#
#   Permission is hereby granted, free of charge, to any person obtaining
#   a copy of this software and associated documentation files (the
#   "Software"), to deal in the Software without restriction, including
#   without limitation the rights to use, copy, modify, merge, publish,
#   distribute, sublicense, and/or sell copies of the Software, and to
#   permit persons to whom the Software is furnished to do so, subject to
#   the following conditions:
#
#   The above copyright notice and this permission notice shall be
#   included in all copies or substantial portions of the Software.
#
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
#   LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
#   OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
#   WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

RealEtc = Etc

module FakeEtc # rubocop:disable Documentation
  @groups = {}
  @users = {}

  # Checks whether FakeEtc is currently activated.
  # @return [Bool] true if FakeEtc is currently activated, false if it
  #   is not
  def self.activated?
    @activated
  end

  # Activates FakeEtc.
  # @return [void]
  def self.activate
    @activated = true
    Object.class_eval do
      remove_const :Etc
      const_set :Etc, FakeEtc
    end
  end

  # Deactivates FakeEtc.
  # @return [void]
  def self.deactivate
    Object.class_eval do
      remove_const :Etc
      const_set :Etc, RealEtc
    end
    @activated = false
  end

  # Runs a code block with FakeEtc.
  # @return [Object] the block's return value
  def self.with
    if activated?
      yield
    else
      begin
        activate
        yield
      ensure
        deactivate
      end
    end
  end

  # Runs a code block without FakeEtc.
  # @return [Object] the block's return value
  def self.without
    if !activated?
      yield
    else
      begin
        deactivate
        yield
      ensure
        activate
      end
    end
  end
end

# Runs a code block with FakeEtc.
#
# @example
#   FakeEtc.add_groups('foo' => { gid: 42, mem: %w(bar baz) })
#   FakeEtc do
#     Etc.getgrnam('foo').gid
#   end
#   # => 42
#
# @return [Object] the block's return value
def FakeEtc(&block) # rubocop:disable Style/MethodName
  return ::FakeEtc unless block
  ::FakeEtc.with(&block)
end
