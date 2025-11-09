class Collection < ApplicationRecord
  has_many :artwork_collections, dependent: :destroy
  has_many :artworks, through: :artwork_collections

  REGIONS = [
    'Australia', 'Brazil', 'Canada', 'India', 'Israel', 'Italy',
    'Netherlands', 'Portugal', 'Spain', 'Switzerland', 
    'United Kingdom', 'USA'
  ].freeze

  scope :published, -> { where(published: true) }

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true

  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "slug", "location", "region", "description", "website", "published",
     "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["artworks", "artwork_collections"]
  end
end
