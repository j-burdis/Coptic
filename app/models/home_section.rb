class HomeSection < ApplicationRecord
  attr_accessor :image

  scope :published, -> { where(published: true) }
  scope :ordered, -> { order(position: :asc) }

  LAYOUTS = ['image_left', 'image_right'].freeze

  def image_url
    return nil unless image_cloudinary_public_id.present?
    Cloudinary::Utils.cloudinary_url(
      image_cloudinary_public_id,
      width: 1200,
      crop: "limit",
      quality: "auto",
      fetch_format: "auto"
    )
  end

  def thumbnail_url
    return nil unless image_cloudinary_public_id.present?
    Cloudinary::Utils.cloudinary_url(
      image_cloudinary_public_id,
      width: 400,
      height: 300,
      crop: "fill",
      quality: "auto",
      fetch_format: "auto"
    )
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "title", "description", "link_url", "link_text", "video_url", "layout", "position", "published", "created_at", "updated_at"]
  end
end
