class Artwork < ApplicationRecord
  attr_accessor :image

  has_many :artwork_collections, dependent: :destroy
  has_many :collections, through: :artwork_collections
  has_many :artwork_exhibitions, dependent: :destroy
  has_many :exhibitions, through: :artwork_exhibitions
  has_many :artwork_relations, dependent: :destroy
  has_many :related_to, through: :artwork_relations, source: :related_artwork

  enum category: {
    paintings: 0,
    prints: 1,
    design: 2,
    indian_leaves: 3,
    indian_waves: 4,
    quantel_paintbox: 5,
    memories_of_bombay_mumbai: 6,
    other: 7
  }

  enum status: {
    active: 0,
    missing: 1,
    destroyed: 2
  }, _prefix: true

  DESIGN_SUBCATEGORIES = [
    'artplate', 'bbc-billboard-project', 'british-council-hq', 
    'broadgate-centre', 'designers-guild', 'evermore', 
    'exhibition-models', 'glyndebourne-festival', 'high-gate-ponds',
    'imax-cinema', 'kolam', 'laylaandmajnun', 'lomonosov-plate',
    'mozart-dances', 'new-worlds-stamp', 'night-music', 'olympic-games',
    'piano', 'pulcinella', 'rhymes-with-silver', 'savitri',
    'the-nutcracker', 'the-way-we-live-now-susan-sontag', 'van-cliburn'
  ].freeze

  INDIAN_COLLECTION_CATEGORIES = [
    'portrait', 'elephants', 'flora_fauna'
  ].freeze

  scope :published, -> { where(published: true) }
  scope :main_collection, -> { where(is_indian_collection: false) }
  scope :indian_collection, -> { where(is_indian_collection: true) }

  validates :title, :slug, :category, presence: true
  validates :slug, uniqueness: true

  def self.ransackable_attributes(auth_object = nil)
    ["id", "title", "slug", "year", "year_end", "medium", "description", "dimensions",
     "category", "subcategory", "status", "published", "is_indian_collection",
     "indian_collection_category", "cloudinary_public_id", "original_filename",
     "artwork_relations_id", "related_to_id",
     "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["collections", "exhibitions", "artwork_collections", "artwork_exhibitions"]
  end

  def thumbnail_url
    return nil unless cloudinary_public_id.present?

    Cloudinary::Utils.cloudinary_url(
      cloudinary_public_id,
      width: 300,
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

  def image_url(transformation = {})
    return nil unless cloudinary_public_id.present?

    default_transformation = {
      quality: 'auto',
      fetch_format: 'auto',
      crop: 'limit'
    }

    Cloudinary::Utils.cloudinary_url(
      cloudinary_public_id,
      default_transformation.merge(transformation)
    )
  end

  def year_range
    return year.to_s unless year_end.present? && year_end != year

    "#{year} - #{year_end}"
  end
end
