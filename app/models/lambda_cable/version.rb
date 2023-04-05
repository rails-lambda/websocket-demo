module LambdaCable
  module Version
    STRING = "1.0.0"
  end
  def self.version
    Gem::Version.new Version::STRING
  end
end
