class Room < ApplicationRecord
  validates_uniqueness_of :name
  has_many :participants, dependent: :destroy
  scope :public_rooms, -> { where(is_private: false) }

  after_create_commit { broadcast_if_public }

  has_many :messages

  def broadcast_if_public
    broadcast_append_to 'rooms' unless self.is_private
  end

  def self.create_private_room(users, room_name)
    single_room = Room.create(name: room_name, is_private: true)
    users.each do |user|
      single_room.participants.create(user_id: user.id)
    end
    single_room
  end
end
