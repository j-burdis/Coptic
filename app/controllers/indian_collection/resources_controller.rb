module IndianCollection
  class ResourcesController < ApplicationController
    layout 'indian_collection'

    def index
      @resources = Resource.published.indian_collection.order(year: :desc, title: :asc)
      @category_title = "Indian Collection Resources"
      @show_grid_view = true

      @earliest_year = @resources.minimum(:year) ||
                       @resources.where.not(date: nil).minimum("EXTRACT(YEAR FROM date)::integer")

      apply_search_filters
      @resources = @resources.page(params[:page]).per(12)
    end

    def show
      @resource = Resource.indian_collection.find_by!(slug: params[:slug])
      @category_title = "Indian Collection Resources"
    end

    private

    def apply_search_filters
      # Keyword search only (like films & audio)
      if params[:s].present?
        search_term = "%#{params[:s]}%"
        @resources = @resources.where(
          "title ILIKE ? OR description ILIKE ? OR author ILIKE ? OR summary ILIKE ?",
          search_term, search_term, search_term, search_term
        )
      end
    end
  end
end
