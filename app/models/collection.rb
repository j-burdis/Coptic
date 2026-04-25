class Collection < ApplicationRecord
  attr_accessor :image

  has_many :artwork_collections, dependent: :destroy
  has_many :artworks, through: :artwork_collections

  REGIONS = [
    'Australia', 'Brazil', 'Canada', 'India', 'Israel', 'Italy',
    'Netherlands', 'Portugal', 'Spain', 'Switzerland', 
    'United Kingdom', 'USA'
  ].freeze

  # validates :region, inclusion: { in: REGIONS}, allow_blank: true

  scope :published, -> { where(published: true) }

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true

  # helper method for getting the collection URL path
  def path
    Rails.application.routes.url_helpers.collection_path(slug)
  end

  # published artworks count in this collection
  def artwork_count
    artworks.published.count
  end

  def thumbnail_url
    return nil unless cloudinary_public_id.present?
    Cloudinary::Utils.cloudinary_url(
      cloudinary_public_id,
      width: 400,
      height: 300,
      crop: "fill",
      quality: "auto",
      fetch_format: "auto"
    )
  end

  def large_url
    return nil unless cloudinary_public_id.present?
    Cloudinary::Utils.cloudinary_url(
      cloudinary_public_id,
      width: 1200,
      crop: "limit",
      quality: "auto",
      fetch_format: "auto"
    )
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "slug", "location", "region", "description", "website", "published",
    "cloudinary_public_id", "original_filename", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["artworks", "artwork_collections"]
  end
end
