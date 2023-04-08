class User
  include GlobalID::Identification
  attr_reader :name

  def self.find(name)
    new(name)
  end

  def initialize(name)
    @name = name
  end

  def id
    name
  end
end
