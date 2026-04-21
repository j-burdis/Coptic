class SearchController < ApplicationController
  def index
    @query = params[:s].to_s.strip

    if @query.length >= 3
      search_term = "%#{@query}%"

      @artworks = Artwork.published.where(
        "title ILIKE ? OR description ILIKE ? OR medium ILIKE ?",
        search_term, search_term, search_term
      ).limit(5)

      @resources = Resource.published.where(
        "title ILIKE ? OR description ILIKE ? OR summary ILIKE ? OR author ILIKE ?",
        search_term, search_term, search_term, search_term
      ).limit(5)

      @news_items = NewsItem.published.where(
        "title ILIKE ? OR content ILIKE ? OR excerpt ILIKE ?",
        search_term, search_term, search_term
      ).limit(5)

      @exhibitions = Exhibition.published.where(
        "title ILIKE ? OR description ILIKE ? OR venue ILIKE ?",
        search_term, search_term, search_term
      ).limit(5)

      @collections = Collection.published.where(
        "name ILIKE ? OR description ILIKE ? OR location ILIKE ?",
        search_term, search_term, search_term
      ).limit(5)

      @total_count = [@artworks, @resources, @news_items, @exhibitions, @collections]
                       .sum(&:count)
    end

    respond_to do |format|
      format.html
      format.json do
        render json: {
          html: render_to_string(
            partial: 'search/results',
            formats: [:html],
            locals: {
              query: @query,
              artworks: @artworks || [],
              resources: @resources || [],
              news_items: @news_items || [],
              exhibitions: @exhibitions || [],
              collections: @collections || [],
              total_count: @total_count || 0
            }
          )
        }
      end
    end
  end
end
