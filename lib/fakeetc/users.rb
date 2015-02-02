module FakeEtc
  class << self
    [:endpwent,
     :getpwent,
     :getpwnam,
     :getpwuid,
     :passwd,
     :setpwent].each do |m|
      define_method(m) do
        fail NotImplementedError, "FakeEtc.#{m} not implemented yet"
      end
    end
  end
end
