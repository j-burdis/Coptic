class Resource < ApplicationRecord
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
