class Message < ApplicationRecord
  belongs_to :room
  validates :content, presence: true
  scope :recent, -> { order(created_at: :desc).limit(20) }
  
  after_create_commit -> { broadcast_prepend_to room }
  after_update_commit -> { broadcast_replace_to room }
  after_destroy_commit -> { broadcast_remove_to room }
end
