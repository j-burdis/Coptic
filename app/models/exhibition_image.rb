class ExhibitionImage < ApplicationRecord
  belongs_to :exhibition

  validates :cloudinary_public_id, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
  
  default_scope { order(position: :asc) }
  
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
end
