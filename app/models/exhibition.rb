class Exhibition < ApplicationRecord
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
    if year_end.present? && year_end != year
      "#{year}-#{year_end}"
    else
      year.to_s
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    ["title", "slug", "year", "year_end", "venue", "location", "description",
     "exhibition_type", "published", "is_indian_collection",
     "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["artworks", "artwork_exhibitions"]
  end
end
