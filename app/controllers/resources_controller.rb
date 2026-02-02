class ResourcesController < ApplicationController
  before_action :set_base_query, only: [
    :films_and_audio, :texts, :texts_subcategory, 
    :publications, :publications_subcategory, :chronology
  ]

  before_action :load_category_pages, only: [
    :index, :films_and_audio, :texts, :texts_subcategory,
    :publications, :publications_subcategory, :chronology
  ]

  def index
    # Set flag to show landing page
    @show_landing = true

    # Load resource categories (we'll use CategoryPage model similar to gallery)
    @resource_categories = CategoryPage.published
                                       .resource_category
                                       .ordered

    @resources_quote = Quote.resources_landing.published.first

    # Fallback: if no category pages exist, show defaults
    return unless @resource_categories.empty?

    @categories_fallback = {
      exhibitions: Exhibition.published.main_collection.count,
      films_and_audio: Resource.published.main_collection.films_and_audio.count,
      texts: Resource.published.main_collection.texts.count,
      publications: Resource.published.main_collection.publications.count,
      chronology: Resource.published.main_collection.chronology.count,
      collections: Collection.published.count
    }
  end

  def films_and_audio
    @category_page = CategoryPage.published.resource_category.find_by(slug: 'films-and-audio')
    @resources = @resources.films_and_audio
    @category_title = "Films & Audio"
    @show_date_filter = false
    @show_grid_view = true
    apply_search_filters
    @resources = @resources.page(params[:page]).per(12)
    render :index
  end

  def texts
    @category_page = CategoryPage.published.resource_category.find_by(slug: 'texts')
    @resources = @resources.texts
    @category_title = "Texts"
    @show_date_filter = true
    @show_subcategory_filter = true
    @text_subcategories = Resource::TEXT_SUBCATEGORIES

    apply_search_and_date_filters
    @resources = @resources.page(params[:page]).per(12)
    render :index
  end

  def texts_subcategory
    @category_page = CategoryPage.published.resource_subcategory.find_by(slug: params[:subcategory])
    @resources = @resources.texts.where(subcategory: params[:subcategory])
    @category_title = "Texts - #{params[:subcategory].titleize}"
    @show_date_filter = true
    @show_subcategory_filter = true
    @text_subcategories = Resource::TEXT_SUBCATEGORIES
    @active_subcategory = params[:subcategory]

    apply_search_and_date_filters
    @resources = @resources.page(params[:page]).per(12)
    render :index
  end

  def publications
    @category_page = CategoryPage.published.resource_category.find_by(slug: 'publications')
    @resources = @resources.publications
    @category_title = "Publications"
    @show_date_filter = true
    @show_subcategory_filter = true
    @publication_subcategories = Resource::PUBLICATION_SUBCATEGORIES

    apply_search_and_date_filters
    @resources = @resources.page(params[:page]).per(12)
    render :index
  end

  def publications_subcategory
    @category_page = CategoryPage.published.resource_subcategory.find_by(slug: params[:subcategory])
    @resources = @resources.publications.where(subcategory: params[:subcategory])
    @category_title = "Publications - #{params[:subcategory].titleize}"
    @show_date_filter = true
    @show_subcategory_filter = true
    @publication_subcategories = Resource::PUBLICATION_SUBCATEGORIES
    @active_subcategory = params[:subcategory]

    apply_search_and_date_filters
    @resources = @resources.page(params[:page]).per(12)
    render :index
  end

  def chronology
    @category_page = CategoryPage.published.resource_category.find_by(slug: 'chronology')
    @resources = @resources.chronology
    @category_title = "Chronology"
    @show_date_filter = true
    @show_decade_list = true

    apply_search_and_date_filters
    @resources = @resources.page(params[:page]).per(20)
    render :index
  end

  def show
    @resource = Resource.find_by!(slug: params[:slug])

    # For breadcrumbs and navigation
    @category_title = @resource.category.titleize
  end

  private

  def set_base_query
    @resources = Resource.published.main_collection.order(year: :desc, title: :asc)
  end

  def load_category_pages
    # Load all category pages for navigation
    @resource_categories = CategoryPage.published.resource_category.ordered
  end

  def apply_search_filters
    # keyword search only (for films & audio)
    if params[:s].present?
      search_term = "%#{params[:s]}%"
      @resources = @resources.where(
        "title ILIKE ? OR description ILIKE ? OR author ILIKE ? OR summary ILIKE ?",
        search_term, search_term, search_term, search_term
      )
    end
  end

  def apply_search_and_date_filters
    # keyword search
    if params[:s].present?
      search_term = "%#{params[:s]}%"
      @resources = @resources.where(
        "title ILIKE ? OR description ILIKE ? OR author ILIKE ? OR summary ILIKE ?",
        search_term, search_term, search_term, search_term
      )
    end

    # date range filter
    return unless params[:dates].present?

    case params[:dates]
    when /(\d{4})-(\d{4})/ # decade range
      start_year = ::Regexp.last_match(1).to_i
      end_year = ::Regexp.last_match(2).to_i
      @resources = @resources.where("year >= ? AND year <= ?", start_year, end_year)
    when /(\d{4})/ # single year
      year = $1.to_i
      @resources = @resources.where(year: year)
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
