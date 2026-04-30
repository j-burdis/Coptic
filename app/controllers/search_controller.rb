class SearchController < ApplicationController
  PER_PAGE = 12

  def index
    @query = params[:s].to_s.strip
    @page = (params[:page] || 1).to_i

    if @query.length >= 3
      search_term = "%#{@query}%"

      all_artworks = prioritised_results(
        Artwork.published,
        title_fields: ["title ILIKE ?"],
        date_fields: [
          "CAST(year AS TEXT) ILIKE ?",
          "CAST(year_end AS TEXT) ILIKE ?",
          "date_display ILIKE ?"
        ],
        body_fields: ["description ILIKE ?", "medium ILIKE ?"],
        term: search_term
      )

      all_resources = prioritised_results(
        Resource.published.where.not(category: :chronology),
        title_fields: ["title ILIKE ?"],
        date_fields: [
          "CAST(year AS TEXT) ILIKE ?",
          "CAST(year_end AS TEXT) ILIKE ?",
          "CAST(EXTRACT(YEAR FROM date) AS TEXT) ILIKE ?"
        ],
        body_fields: ["description ILIKE ?", "summary ILIKE ?", "author ILIKE ?"],
        term: search_term
      )

      all_news_items = prioritised_results(
        NewsItem.published,
        title_fields: ["title ILIKE ?"],
        date_fields: [
          "CAST(EXTRACT(YEAR FROM date) AS TEXT) ILIKE ?"
        ],
        body_fields: ["content ILIKE ?", "excerpt ILIKE ?"],
        term: search_term
      )

      all_exhibitions = prioritised_results(
        Exhibition.published,
        title_fields: ["title ILIKE ?"],
        date_fields: [
          "CAST(EXTRACT(YEAR FROM start_date) AS TEXT) ILIKE ?",
          "CAST(EXTRACT(YEAR FROM end_date) AS TEXT) ILIKE ?"
        ],
        body_fields: ["description ILIKE ?", "venue ILIKE ?", "location ILIKE ?"],
        term: search_term
      )

      all_collections = prioritised_results(
        Collection.published,
        title_fields: ["name ILIKE ?"],
        date_fields: [],
        body_fields: ["description ILIKE ?", "location ILIKE ?"],
        term: search_term
      )

      # combine all results maintaining priority order
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

  def prioritised_results(scope, title_fields:, date_fields:, body_fields:, term:)
    title_matches = query_fields(scope, title_fields, term)

    date_matches = if date_fields.any?
      date_only_ids = query_fields(scope, date_fields, term).pluck(:id) - title_matches.pluck(:id)
      scope.where(id: date_only_ids)
    else
      scope.none
    end

    all_fields = title_fields + date_fields + body_fields
    all_match_ids = query_fields(scope, all_fields, term).pluck(:id)
    body_only_ids = all_match_ids - title_matches.pluck(:id) - date_matches.pluck(:id)
    body_matches = scope.where(id: body_only_ids)

    title_matches.to_a + date_matches.to_a + body_matches.to_a
  end

  def query_fields(scope, fields, term)
    return scope.none if fields.empty?
    scope.where(
      fields.map { |f| "(#{f})" }.join(" OR "),
      *Array.new(fields.length, term)
    )
  end
end
