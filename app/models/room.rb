class Room < ApplicationRecord
  has_many :messages
  validates :name, presence: true
  validates :name, uniqueness: true

  scope :recent, -> { order(updated_at: :desc).limit(10) }
end
