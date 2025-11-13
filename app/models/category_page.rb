class CategoryPage < ApplicationRecord
  attr_accessor :image

  enum page_type: {
    gallery_category: 0,
    design_subcategory: 1,
    special_collection: 2
  }

  # Map slugs to their corresponding artwork categories/scopes
  GALLERY_CATEGORIES = {
    'paintings' => { title: 'Paintings', scope: :paintings },
    'prints' => { title: 'Prints', scope: :prints },
    'design' => { title: 'Design', scope: :design },
    'indian-leaves' => { title: 'Indian Leaves', scope: :indian_leaves },
    'indian-waves' => { title: 'Indian Waves', scope: :indian_waves },
    'quantel-paintbox' => { title: 'Quantel Paintbox', scope: :quantel_paintbox },
    'memories-of-bombay-mumbai' => { title: 'Memories of Bombay / Mumbai', scope: :memories_of_bombay_mumbai },
    'other' => { title: 'Other', scope: :other }
  }.freeze

  SPECIAL_COLLECTIONS = {
    'missing-works' => { title: 'Missing Works', scope: :status_missing },
    'destroyed' => { title: 'Destroyed', scope: :status_destroyed },
    'all' => { title: 'All Artworks', scope: :all }
  }.freeze

  scope :published, -> { where(published: true) }
  scope :ordered, -> { order(position: :asc, title: :asc) }

  validates :slug, presence: true, uniqueness: true
  validates :title, presence: true
  validates :page_type, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["id", "slug", "title", "description", "page_type", "position", "published", 
     "cloudinary_public_id", "original_filename", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  # Get artwork count for this category
  def artwork_count
    return 0 unless slug.present?

    scope = if gallery_category?
      GALLERY_CATEGORIES.dig(slug, :scope)
    elsif special_collection?
      SPECIAL_COLLECTIONS.dig(slug, :scope)
    elsif design_subcategory?
      return Artwork.published.main_collection.design.where(subcategory: slug).count
    end

    return 0 unless scope

    if scope == :all
      Artwork.published.main_collection.count
    else
      Artwork.published.main_collection.public_send(scope).count
    end
  end

  def thumbnail_url
    return nil unless cloudinary_public_id.present?

    Cloudinary::Utils.cloudinary_url(
      cloudinary_public_id,
      width: 600,
      height: 400,
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

  def hero_url
    return nil unless cloudinary_public_id.present?

    Cloudinary::Utils.cloudinary_url(
      cloudinary_public_id,
      width: 1600,
      height: 600,
      crop: "fill",
      quality: "auto",
      fetch_format: "auto"
    )
  end

  def image_url(transformation = {})
    return nil unless cloudinary_public_id.present?

    default_transformation = {
      quality: 'auto',
      fetch_format: 'auto'
    }

    Cloudinary::Utils.cloudinary_url(
      cloudinary_public_id,
      default_transformation.merge(transformation)
    )
  end
end
