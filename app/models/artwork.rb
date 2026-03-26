class Artwork < ApplicationRecord
  attr_accessor :image

  before_validation :generate_slug, if: -> { slug.blank? && title.present? }

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
    ['artplate', 'Artplate'],
    ['bbc-billboard-project', 'BBC Billboard Project'],
    ['british-council-hq', 'British Council HQ'],
    ['broadgate-centre', 'Broadgate Centre'],
    ['designers-guild', "Designers' Guild"],
    ['evermore', 'Evermore'],
    ['exhibition-models', 'Exhibition Models'],
    ['glyndebourne-festival', 'Glyndebourne Festival'],
    ['high-gate-ponds', 'High Gate Ponds'],
    ['imax-cinema', 'IMAX Cinema'],
    ['kolam', 'Kolam'],
    ['layla-and-majnun', 'Layla and Majnun'],
    ['lomonosov-plate', 'Lomonosov Plate'],
    ['mozart-dances', 'Mozart Dances'],
    ['new-worlds-stamp', 'New Worlds Stamp'],
    ['night-music', 'Night Music'],
    ['olympic-games', 'Olympic Games'],
    ['piano', 'Piano'],
    ['pulcinella', 'Pulcinella'],
    ['rhymes-with-silver', 'Rhymes with Silver'],
    ['savitri', 'Savitri'],
    ['the-nutcracker', 'The Nutcracker'],
    ['the-way-we-live-now-susan-sontag', 'The Way We Live Now - Susan Sontag'],
    ['van-cliburn', 'Van Cliburn']
  ].freeze

  INDIAN_COLLECTION_CATEGORIES = [
    'portrait', 'elephants', 'flora_fauna'
  ].freeze

  scope :published, -> { where(published: true) }
  scope :main_collection, -> { where(is_indian_collection: false) }
  scope :indian_collection, -> { where(is_indian_collection: true) }

  validates :title, :slug, presence: true
  validates :category, presence: true, unless: :is_indian_collection?
  validates :slug, uniqueness: true

  def path
    if is_indian_collection?
      Rails.application.routes.url_helpers.indian_collection_artwork_path(slug)
    else
      Rails.application.routes.url_helpers.artwork_path(slug)
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "title", "slug", "year", "year_end", "medium", "description", "dimensions",
     "category", "subcategory", "status", "published", "is_indian_collection",
     "indian_collection_category", "cloudinary_public_id", "original_filename",
     "date_display", "artwork_relations_id", "related_to_id",
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
    if date_display.present?
      date_display
    elsif year_end.present? && year_end != year
      "#{year} - #{year_end}"
    elsif year.present?
      year.to_s
    else
      nil
    end
  end

  private

  def generate_slug
    self.slug = title.parameterize
  end
end
