module FakeEtc
  def self.sysconfdir
    RealEtc.sysconfdir
  end

  def self.systmpdir
    RealEtc.systmpdir
  end
end
