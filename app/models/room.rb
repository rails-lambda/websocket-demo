class Room < ApplicationRecord
  has_many :messages
  validates :name, presence: true
  validates :name, uniqueness: true
end
