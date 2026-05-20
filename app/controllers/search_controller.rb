class SearchController < ApplicationController
  PER_PAGE = 12

  def index
    @query = params[:s].to_s.strip
    @page = (params[:page] || 1).to_i

    if @query.length >= 3
      all_artworks = prioritised_results(
        Artwork.published,
        scope: Artwork,
        date_fields: [
          "CAST(year AS TEXT) ILIKE ?",
          "CAST(year_end AS TEXT) ILIKE ?",
          "date_display ILIKE ?"
        ]
      )

      all_resources = prioritised_results(
        Resource.published.where.not(category: :chronology),
        scope: Resource,
        date_fields: [
          "CAST(year AS TEXT) ILIKE ?",
          "CAST(year_end AS TEXT) ILIKE ?",
          "CAST(EXTRACT(YEAR FROM date) AS TEXT) ILIKE ?"
        ]
      )

      all_news_items = prioritised_results(
        NewsItem.published,
        scope: NewsItem,
        date_fields: [
          "CAST(EXTRACT(YEAR FROM date) AS TEXT) ILIKE ?"
        ]
      )

      all_exhibitions = prioritised_results(
        Exhibition.published,
        scope: Exhibition,
        date_fields: [
          "CAST(EXTRACT(YEAR FROM start_date) AS TEXT) ILIKE ?",
          "CAST(EXTRACT(YEAR FROM end_date) AS TEXT) ILIKE ?"
        ]
      )

      all_collections = prioritised_results(
        Collection.published,
        scope: Collection,
        date_fields: []
      )

      all_results = all_artworks + all_resources + all_news_items + all_exhibitions + all_collections

      @total_count = all_results.length
      @total_pages = (@total_count.to_f / PER_PAGE).ceil
      offset = (@page - 1) * PER_PAGE
      @results = all_results[offset, PER_PAGE] || []
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
              results: @results || [],
              total_count: @total_count || 0,
              total_pages: @total_pages || 0,
              current_page: @page
            }
          )
        }
      end
    end
  end

  private

  def prioritised_results(base_scope, scope:, date_fields:)
    search_term = "%#{@query}%"

    # pg_search ranked results (title weight + frequency handled by postgres)
    text_matches = scope.pg_search(@query).merge(base_scope)
    text_ids = text_matches.pluck(:id)

    # date matching as raw SQL, tsearch doesn't handle numbers well
    if date_fields.any?
      date_only_ids = base_scope
                      .where(
                        date_fields.map { |f| "(#{f})" }.join(" OR "),
                        *Array.new(date_fields.length, search_term)
                      )
                      .pluck(:id) - text_ids
      date_matches = base_scope.where(id: date_only_ids)
    else
      date_matches = base_scope.none
    end

    text_matches.to_a + date_matches.to_a
  end

  def query_fields(scope, fields, term)
    return scope.none if fields.empty?

    scope.where(
      fields.map { |f| "(#{f})" }.join(" OR "),
      *Array.new(fields.length, term)
    )
  end
end
