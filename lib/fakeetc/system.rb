module FakeEtc # rubocop:disable Documentation
  # @return [String] the system's configuration directory
  def self.sysconfdir
    RealEtc.sysconfdir
  end

  # @return [String] the system's temp directory
  def self.systmpdir
    RealEtc.systmpdir
  end
end
