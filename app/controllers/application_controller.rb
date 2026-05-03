class ApplicationController < ActionController::Base
  # only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

  def route_not_found
    path = params[:path]

    match = find_closest_match(path)

    if match
      redirect_to match[:url], status: :found
    else
      redirect_to root_path, alert: "No matching page found for \"#{path}\""
    end
  end

  def handle_record_not_found
    path = request.path.gsub(/^\//, '')
    match = find_closest_match(path)

    if match
      redirect_to match[:url], status: :found
    else
      redirect_to root_path, alert: "No matching page found for \"#{path}\""
    end
  end

  private

  def find_closest_match(path)
    query = path.gsub(/^\//, '').split('/').last&.downcase
    return nil if query.blank?

    candidates = []

    artwork = Artwork.published.where("slug ILIKE ?", "#{query}%").order(:slug).first
    candidates << { slug: artwork.slug, url: artwork.path } if artwork

    resource = Resource.published.where("slug ILIKE ?", "#{query}%").order(:slug).first
    candidates << { slug: resource.slug, url: resource.path } if resource

    exhibition = Exhibition.published.where("slug ILIKE ?", "#{query}%").order(:slug).first
    candidates << { slug: exhibition.slug, url: exhibition_path(exhibition.slug) } if exhibition

    collection = Collection.published.where("slug ILIKE ?", "#{query}%").order(:slug).first
    candidates << { slug: collection.slug, url: collection_path(collection.slug) } if collection

    news_item = NewsItem.published.where("slug ILIKE ?", "#{query}%").order(:slug).first
    candidates << { slug: news_item.slug, url: news_path(news_item.slug) } if news_item

    return nil if candidates.empty?

    candidates.min_by { |c| c[:slug] }
  end
end
