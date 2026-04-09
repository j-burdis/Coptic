class NewsItem < ApplicationRecord
  attr_accessor :image

  validates :title, :slug, presence: true
  validates :slug, uniqueness: true

  before_validation :generate_slug, if: -> { slug.blank? && title.present? }

  scope :published, -> { where(published: true).order(published_at: :desc) }

  def path
    Rails.application.routes.url_helpers.news_path(slug)
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
    ["id", "title", "slug", "content", "excerpt", "published_at", "published",
     "cloudinary_public_id", "image_caption", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  private

  def generate_slug
    self.slug = title.parameterize
  end
end
