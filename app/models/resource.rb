class Resource < ApplicationRecord
  attr_accessor :image

  before_validation :set_chronology_title, if: :chronology?
  before_validation :clear_slug_for_chronology, if: :chronology?

  has_many :resource_exhibitions, dependent: :destroy
  has_many :exhibitions, through: :resource_exhibitions

  enum category: {
    films_and_audio: 0,
    texts: 1,
    publications: 2,
    chronology: 3
  }

  TEXT_SUBCATEGORIES = [
    ['critical-essays', 'Critical Essays'],
    ['interviews', 'Interviews'],
    ['selected-reviews', 'Selected Reviews'],
    ['the-artists-words', "The Artist's Words"]
  ].freeze

  PUBLICATION_SUBCATEGORIES = [
    ['posters-postcards', 'Posters & Postcards'],
    ['selected-books', 'Selected Books'],
    ['selected-catalogues', 'Selected Catalogues']
  ].freeze
  scope :published, -> { where(published: true) }
  scope :main_collection, -> { where(is_indian_collection: false) }
  scope :indian_collection, -> { where(is_indian_collection: true) }

  validates :title, :category, presence: true
  validates :slug, presence: true, uniqueness: true, unless: :chronology?

  # helper method for getting the resource URL path
  def path
    return nil if chronology?
    Rails.application.routes.url_helpers.resource_path(slug)
  end

  def chronology?
    category == 'chronology'
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

    if date.present?
      if show_day?
        "#{ordinalize_day(date)} #{date.strftime('%B %Y')}" # full date: "16th May 2024"
      else
        date.strftime('%B %Y') # month only: "May 2024"
      end
    else
      ''
    end
  end

  def year_value
    date.present? ? date.year : year
  end

  def year_display
    if year_end.present? && year_end != year
      "#{year} - #{year_end}"
    elsif year.present?
      year.to_s
    else
      ''
    end
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

  private

  def set_chronology_title
    if title.blank?
      self.title = year_display.presence || "Chronology Entry"
    end
  end

  def clear_slug_for_chronology
    self.slug = nil if slug.blank?
  end

  def ordinalize_day(date)
    day = date.day
    case day
    when 1, 21, 31 then "#{day}st"
    when 2, 22 then "#{day}nd"
    when 3, 23 then "#{day}rd"
    else "#{day}th"
    end
  end
end
