class Resource < ApplicationRecord
  attr_accessor :image

  enum category: {
    films_and_audio: 0,
    texts: 1,
    publications: 2,
    chronology: 3
  }

  TEXT_SUBCATEGORIES = [
    'critical-essays', 'interviews', 'selected-reviews', 'the-artists-words'
  ].freeze

  PUBLICATION_SUBCATEGORIES = [
    'posters-postcards', 'selected-books', 'selected-catalogues'
  ].freeze

  scope :published, -> { where(published: true) }
  scope :main_collection, -> { where(is_indian_collection: false) }
  scope :indian_collection, -> { where(is_indian_collection: true) }

  validates :title, :slug, :category, presence: true
  validates :slug, uniqueness: true

  # helper method for getting the resource URL path
  def path
    Rails.application.routes.url_helpers.resource_path(slug)
  end

  # helper for cloudinary image URLs (optional - only if you use images)
  def thumbnail_url(width: 800, height: 600, crop: :fill)
    return nil unless cloudinary_public_id.present?

    Cloudinary::Utils.cloudinary_url(
      cloudinary_public_id,
      width: width,
      height: height,
      crop: crop,
      quality: 'auto',
      fetch_format: 'auto'
    )
  end

  def image_url
    return nil unless cloudinary_public_id.present?

    Cloudinary::Utils.cloudinary_url(
      cloudinary_public_id,
      quality: 'auto',
      fetch_format: 'auto'
    )
  end

  def date_display
    return year.to_s if year.present? && date.blank?
    return date.strftime('%-d %B %Y') if date.present? && show_full_date?
    return date.strftime('%B %Y') if date.present?

    ''
  end

  def show_full_date?
    # full date shown if day is not the 1st (assuming month-only dates default to 1st)
    date.present? && date.day != 1
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "title", "slug", "category", "subcategory", "year", "author",
     "summary", "description", "content", "external_url",
     "cloudinary_public_id", "original_filename",
     "video_type", "video_id", "embed_code", "duration_seconds",
     "published", "is_indian_collection",
     "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
