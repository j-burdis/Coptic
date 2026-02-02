class CategoryPage < ApplicationRecord
  attr_accessor :image

  enum page_type: {
    gallery_category: 0,
    design_subcategory: 1,
    special_collection: 2,
    resource_category: 3,
    resource_subcategory: 4
  }

  # map slugs to their corresponding artwork categories/scopes
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

  RESOURCE_CATEGORIES = {
    'exhibitions' => { title: 'Exhibitions', count_method: :exhibitions },
    'films-and-audio' => { title: 'Films & Audio', count_method: :films_and_audio },
    'texts' => { title: 'Texts', count_method: :texts },
    'publications' => { title: 'Publications', count_method: :publications },
    'chronology' => { title: 'Chronology', count_method: :chronology },
    'collections' => { title: 'Collections', count_method: :collections }
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

  # path based on page type and slug
  def path
    # gallery categories
    case slug
    when 'paintings' then Rails.application.routes.url_helpers.gallery_paintings_path
    when 'prints' then Rails.application.routes.url_helpers.gallery_prints_path
    when 'design' then Rails.application.routes.url_helpers.gallery_design_path
    when 'indian-leaves' then Rails.application.routes.url_helpers.gallery_indian_leaves_path
    when 'indian-waves' then Rails.application.routes.url_helpers.gallery_indian_waves_path
    when 'quantel-paintbox' then Rails.application.routes.url_helpers.gallery_quantel_paintbox_path
    when 'memories-of-bombay-mumbai' then Rails.application.routes.url_helpers.gallery_memories_of_bombay_mumbai_path
    when 'other' then Rails.application.routes.url_helpers.gallery_other_path

    # special collections
    when 'missing-works' then Rails.application.routes.url_helpers.gallery_missing_works_path
    when 'destroyed' then Rails.application.routes.url_helpers.gallery_destroyed_path
    when 'all' then Rails.application.routes.url_helpers.gallery_all_path

    # resource categories
    when 'exhibitions' then Rails.application.routes.url_helpers.resources_exhibitions_path
    when 'films-and-audio' then Rails.application.routes.url_helpers.resources_films_and_audio_path
    when 'texts' then Rails.application.routes.url_helpers.resources_texts_path
    when 'publications' then Rails.application.routes.url_helpers.resources_publications_path
    when 'chronology' then Rails.application.routes.url_helpers.resources_chronology_path
    when 'collections' then Rails.application.routes.url_helpers.resources_collections_path

    else
      # deisgn and resource subcategories
      if resource_subcategory?
        if slug.in?(Resource::TEXT_SUBCATEGORIES)
          Rails.application.routes.url_helpers.resources_texts_subcategory_path(subcategory: slug)
        elsif slug.in?(Resource::PUBLICATION_SUBCATEGORIES)
          Rails.application.routes.url_helpers.resources_publications_subcategory_path(subcategory: slug)
        else
          Rails.application.routes.url_helpers.resources_path
        end
      else
        Rails.application.routes.url_helpers.gallery_root_path
      end
    end
  end

  # get artwork count for category
  def artwork_count
    return 0 unless slug.present?

    # gallery categories
    if gallery_category?
      scope = GALLERY_CATEGORIES.dig(slug, :scope)
      return 0 unless scope

      if scope == :all
        Artwork.published.main_collection.count
      else
        Artwork.published.main_collection.public_send(scope).count
      end

    # special collections
    elsif special_collection?
      scope = SPECIAL_COLLECTIONS.dig(slug, :scope)
      return 0 unless scope

      if scope == :all
        Artwork.published.main_collection.count
      else
        Artwork.published.main_collection.public_send(scope).count
      end

    # design subcategories
    elsif design_subcategory?
      Artwork.published.main_collection.design.where(subcategory: slug).count

    # resource categories
    elsif resource_category?
      case slug
      when 'exhibitions'
        Exhibition.published.main_collection.count
      when 'films-and-audio'
        Resource.published.main_collection.films_and_audio.count
      when 'texts'
        Resource.published.main_collection.texts.count
      when 'publications'
        Resource.published.main_collection.publications.count
      when 'chronology'
        Resource.published.main_collection.chronology.count
      when 'collections'
        Collection.published.count
      else
        0
      end

    # resource subcategories
    elsif resource_subcategory?
      if slug.in?(Resource::TEXT_SUBCATEGORIES)
        Resource.published.main_collection.texts.where(subcategory: slug).count
      elsif slug.in?(Resource::PUBLICATION_SUBCATEGORIES)
        Resource.published.main_collection.publications.where(subcategory: slug).count
      else
        0
      end

    else
      0
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
