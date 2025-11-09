class NewsItem < ApplicationRecord
  validates :title, :slug, presence: true
  validates :slug, uniqueness: true

  scope :published, -> { where(published: true).order(published_at: :desc) }

  def self.ransackable_attributes(auth_object = nil)
    ["id", "title", "slug", "content", "excerpt", "published_at", "published",
     "cloudinary_public_id", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
