class Exhibition < ApplicationRecord
  attr_accessor :image

  has_many :artwork_exhibitions, dependent: :destroy
  has_many :artworks, through: :artwork_exhibitions

  enum exhibition_type: {
    solo_shows: 0,
    group_shows: 1,
    paintings: 2,
    prints: 3,
    other: 4
  }

  scope :published, -> { where(published: true) }
  scope :main_collection, -> { where(is_indian_collection: false) }
  scope :indian_collection, -> { where(is_indian_collection: true) }

  validates :title, :slug, presence: true
  validates :slug, uniqueness: true

  # helper method for getting the exhibition URL path
  def path
    Rails.application.routes.url_helpers.exhibition_path(slug)
  end

  # published artworks count  in this exhibition
  def artwork_count
    artworks.published.count
  end

  # display year range
  def year_display
    if end_date.present? && end_date != start_date
      if start_date.year == end_date.year
        # Same year: "28th March - 12th July 2026"
        "#{ordinalize_day(start_date)} #{start_date.strftime('%B')} - #{ordinalize_day(end_date)} #{end_date.strftime('%B %Y')}"
      else
        # Different years: "28th March 2025 - 12th July 2026"
        "#{ordinalize_day(start_date)} #{start_date.strftime('%B %Y')} - #{ordinalize_day(end_date)} #{end_date.strftime('%B %Y')}"
      end
    elsif start_date.present?
      "#{ordinalize_day(start_date)} #{start_date.strftime('%B %Y')}"
    else
      ''
    end
  end

  def year
    start_date&.year
  end

  def year_end
    end_date&.year
  end

  def self.ransackable_attributes(auth_object = nil)
    ["title", "slug", "year", "year_end", "venue", "location", "description",
     "exhibition_type", "published", "is_indian_collection",
     "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["artworks", "artwork_exhibitions"]
  end

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

  private

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
