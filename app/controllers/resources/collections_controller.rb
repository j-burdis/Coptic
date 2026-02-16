class Resources::CollectionsController < ApplicationController
  before_action :set_base_query, only: [:index]
  before_action :load_category_pages, only: [:index]

  def index
    @category_title = "Collections"
    @show_date_filter = false
    @show_region_filter = true
    @regions = Collection.published.distinct.pluck(:region).compact.sort
    # @regions = Collection::REGIONS

    # region filter
    if params[:region].present?
      @collections = @collections.where('LOWER(region) = ?', params[:region].downcase)
      @active_region = params[:region]
    end

    # keyword search
    if params[:s].present?
      search_term = "%#{params[:s]}%"
      @collections = @collections.where(
        "name ILIKE ? OR location ILIKE ? OR description ILIKE ?",
        search_term, search_term, search_term
      )
    end

    @collections = @collections.order(region: :asc, name: :asc)
    @collections = @collections.page(params[:page]).per(12)
  end

  private

  def set_base_query
    @collections = Collection.published
  end

  def load_category_pages
    # load resource categories for navigation context
    @resource_categories = CategoryPage.published.resource_category.ordered
  end
end
