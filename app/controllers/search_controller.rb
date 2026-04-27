class SearchController < ApplicationController
  def index
    @query = params[:s].to_s.strip

    if @query.length >= 3
      search_term = "%#{@query}%"

      @artworks = prioritised_results(
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

      @resources = prioritised_results(
        Resource.published,
        title_fields: ["title ILIKE ?"],
        date_fields: [
          "CAST(year AS TEXT) ILIKE ?",
          "CAST(year_end AS TEXT) ILIKE ?",
          "CAST(EXTRACT(YEAR FROM date) AS TEXT) ILIKE ?"
        ],
        body_fields: ["description ILIKE ?", "summary ILIKE ?", "author ILIKE ?"],
        term: search_term
      )

      @news_items = prioritised_results(
        NewsItem.published,
        title_fields: ["title ILIKE ?"],
        date_fields: [
          "CAST(EXTRACT(YEAR FROM date) AS TEXT) ILIKE ?"
        ],
        body_fields: ["content ILIKE ?", "excerpt ILIKE ?"],
        term: search_term
      )

      @exhibitions = prioritised_results(
        Exhibition.published,
        title_fields: ["title ILIKE ?"],
        date_fields: [
          "CAST(EXTRACT(YEAR FROM start_date) AS TEXT) ILIKE ?",
          "CAST(EXTRACT(YEAR FROM end_date) AS TEXT) ILIKE ?"
        ],
        body_fields: ["description ILIKE ?", "venue ILIKE ?", "location ILIKE ?"],
        term: search_term
      )

      @collections = prioritised_results(
        Collection.published,
        title_fields: ["name ILIKE ?"],
        date_fields: [],
        body_fields: ["description ILIKE ?", "location ILIKE ?"],
        term: search_term
      )

      @total_count = [@artworks, @resources, @news_items, @exhibitions, @collections]
                       .sum(&:length)
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
