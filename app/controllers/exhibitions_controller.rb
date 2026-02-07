class ExhibitionsController < ApplicationController
  before_action :set_base_query, only: %i[index by_type]
  before_action :load_category_pages, only: %i[index by_type]

  def index
    @category_title = "Exhibitions"
    @show_date_filter = true
    @show_type_filter = true
    @exhibition_types = Exhibition.exhibition_types.keys.map { |k| [k.titleize, k] }

    # apply type filter if present
    if params[:type].present? && Exhibition.exhibition_types.key?(params[:type])
      @exhibitions = @exhibitions.where(exhibition_type: params[:type])
      @active_type = params[:type]
    end

    apply_search_and_date_filters
    @exhibitions = @exhibitions.page(params[:page]).per(12)
  end

  def by_type
    @exhibitions = @exhibitions.where(exhibition_type: params[:exhibition_type])
    @category_title = "Exhibitions - #{params[:exhibition_type].titleize}"
    @show_date_filter = true
    @show_type_filter = true
    @exhibition_types = Exhibition.exhibition_types.keys.map { |k| [k.titleize, k] }
    @active_type = params[:exhibition_type]

    apply_search_and_date_filters
    @exhibitions = @exhibitions.page(params[:page]).per(12)
    render :index
  end

  def show
    @exhibition = Exhibition.find_by!(slug: params[:slug])
    @artworks = @exhibition.artworks.published.order(year: :desc, title: :asc)
  end

  private

  def set_base_query
    @exhibitions = Exhibition.published.main_collection.order(start_date: :desc, title: :asc)
  end

  def load_category_pages
    # load resource categories for navigation context
    @resource_categories = CategoryPage.published.resource_category.ordered
  end

  def apply_search_and_date_filters
    # keyword search
    if params[:s].present?
      search_term = "%#{params[:s]}%"
      @exhibitions = @exhibitions.where(
        "title ILIKE ? OR description ILIKE ? OR venue ILIKE ? OR location ILIKE ?",
        search_term, search_term, search_term, search_term
      )
    end

    # date range filter
    return unless params[:dates].present?

    case params[:dates]
    when /(\d{4})-(\d{4})/ # decade range
      start_year = ::Regexp.last_match(1).to_i
      end_year = ::Regexp.last_match(2).to_i
      decade_start = Date.new(start_year, 1, 1)
      decade_end = Date.new(end_year, 12, 31)

      @exhibitions = @exhibitions.where(
        "(year >= ? AND year <= ?) OR (year_end >= ? AND year_end <= ?) OR (year <= ? AND year_end >= ?)",
        decade_start, decade_end, decade_start, decade_end, decade_start, decade_end
      )
    when /(\d{4})/ # single year
      year = $1.to_i
      year_start = Date.new(year, 1, 1)
      year_end = Date.new(year, 12, 31)
      @exhibitions = @exhibitions.where(
        "(start_date >= ? AND start_date <= ?) OR (end_date >= ? AND end_date <= ?) OR (start_date <= ? AND end_date >= ?)",
        year_start, year_end, year_start, year_end, year_start, year_end
      )
    end
  end

  def decade_ranges
    current_year = Date.current.year
    start_decade = 1940

    decades = []
    (start_decade..current_year).step(10) do |year|
      decade_start = year
      decade_end = [year + 9, current_year].min
      decades << ["#{decade_start}-#{decade_end}", "#{decade_start}-#{decade_end}"]
    end

    decades.reverse
  end
  helper_method :decade_ranges
end
