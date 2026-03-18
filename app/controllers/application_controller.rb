class ApplicationController < ActionController::Base
  # only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def route_not_found
    path = params[:path]

    # find matching artwork, resource, exhibition, or collection
    match = find_closest_match(path)

    if match
      redirect_to match[:url], status: :moved_permanently
    else
      # 404 page
      render file: "#{Rails.root}/public/404.html", status: :not_found, layout: false
    end
  end

  private

  def find_closest_match(path)
    # clean the path (remove leading slash, take first segment)
    query = path.gsub(/^\//, '').split('/').first&.downcase
    return nil if query.blank?

    artwork = Artwork.published.where("slug LIKE ?", "#{query}%").order(:slug).first
    return { url: artwork_path(artwork.slug), type: 'artwork' } if artwork

    resource = Resource.published.where("slug LIKE ?", "#{query}%").order(:slug).first
    return { url: resource_path(resource.slug), type: 'resource' } if resource

    exhibition = Exhibition.published.where("slug LIKE ?", "#{query}%").order(:slug).first
    return { url: exhibition_path(exhibition.slug), type: 'exhibition' } if exhibition

    collection = Collection.published.where("slug LIKE ?", "#{query}%").order(:slug).first
    return { url: collection_path(collection.slug), type: 'collection' } if collection

    nil
  end
end
