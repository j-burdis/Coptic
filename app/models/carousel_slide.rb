class CarouselSlide < ApplicationRecord
  attr_accessor :image

  belongs_to :artwork

  validates :artwork, presence: true

  scope :published, -> { where(published: true) }
  scope :ordered, -> { order(position: :asc) }

  def image_url
    return nil unless cloudinary_public_id.present?
    Cloudinary::Utils.cloudinary_url(
      cloudinary_public_id,
      width: 1920,
      crop: "limit",
      quality: "auto",
      fetch_format: "auto"
    )
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "artwork_id", "quote_text", "quote_attribution_name", "quote_attribution_date", "position", "published", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["artwork"]
  end
end
