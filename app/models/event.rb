class Event < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :organizers, class_name: "user", foreign_key: "id", optional: true
  has_many :attendances
  has_many :events, :through => :attendances

  has_many :taggings
  has_many :tags, through: :taggings

  def all_tags=(names)
    self.tags = names.split(",").map do |t|
      Tag.where(name: t.strip).first_or_create!
    end
  end

  def all_tags
    tags.map(&:name).join(", ")
  end

  def self.tag_counts
    Tag.select("tags.name, count(taggings.tag_id) as count").joins(:taggings).group("taggings.tag_id, tags.id, tags.name")
    # Tag.select("tags.id, tags.name,count(taggings.tag_id) as count").except(name: exclude).joins(:taggings).group("taggings.tag_id, tags.id, tags.name").order("count DESC").limit(5)
  end

  

  def self.event_owner(organizer_id)
    User.find_by id: organizer_id
  end

  def self.pending_requests(event_id)
    Attendance.where(event_id: event_id, state: 'request_sent')
  end

  def self.show_accepted_attendees(event_id)
    Attendance.accepted.where(event_id: event_id)
  end
  def self.show_my_events(organizer_id)
    Event.where(organizer_id: organizer_id)
  end

  def self.tagged_with(name)
    Tag.find_by_name!(name).events
  end
end