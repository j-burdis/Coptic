module IndianCollection
  module Gallery
    class ArtworksController < ApplicationController
      layout 'indian_collection'

      before_action :set_base_query, only: [:index, :portrait, :elephants, :flora_fauna]
      before_action :load_category_pages

      def index
        @category_title = "Indian Collection Gallery"
        @show_date_filter = true

        @earliest_year = @artworks.minimum(:year)

        apply_search_and_date_filters
        @artworks = @artworks.page(params[:page]).per(12)
      end

      def portrait
        @category_page = CategoryPage.published.indian_collection_gallery_category.find_by(slug: 'portrait')
        @artworks = @artworks.where(indian_collection_category: 'portrait')
        @category_title = "Portrait"
        @show_date_filter = true

        @earliest_year = @artworks.minimum(:year)

        apply_search_and_date_filters
        @artworks = @artworks.page(params[:page]).per(12)
        render :index
      end

      def elephants
        @category_page = CategoryPage.published.indian_collection_gallery_category.find_by(slug: 'elephants')
        @artworks = @artworks.where(indian_collection_category: 'elephants')
        @category_title = "Elephants"
        @show_date_filter = true

        @earliest_year = @artworks.minimum(:year)

        apply_search_and_date_filters
        @artworks = @artworks.page(params[:page]).per(12)
        render :index
      end

      def flora_fauna
        @category_page = CategoryPage.published.indian_collection_gallery_category.find_by(slug: 'flora-fauna')
        @artworks = @artworks.where(indian_collection_category: 'flora_fauna')
        @category_title = "Flora & Fauna"
        @show_date_filter = true

        @earliest_year = @artworks.minimum(:year)

        apply_search_and_date_filters
        @artworks = @artworks.page(params[:page]).per(12)
        render :index
      end

      private

      def set_base_query
        @artworks = Artwork.published.indian_collection.order(year: :desc, title: :asc)
      end

      def load_category_pages
        @gallery_categories = CategoryPage.published.indian_collection_gallery_category.ordered
      end

      def apply_search_and_date_filters
        if params[:s].present?
          search_term = "%#{params[:s]}%"
          @artworks = @artworks.where(
            "title ILIKE ? OR description ILIKE ? OR medium ILIKE ?", 
            search_term, search_term, search_term
          )
        end

        if params[:dates].present?
          case params[:dates]
          when /(\d{4})-(\d{4})/
            start_year = $1.to_i
            end_year = $2.to_i
            @artworks = @artworks.where(
              "(year >= ? AND year <= ?) OR (year_end >= ? AND year_end <= ?) OR (year <= ? AND year_end >= ?)",
              start_year, end_year, start_year, end_year, start_year, end_year
            )
          when /(\d{4})/
            year = $1.to_i
            @artworks = @artworks.where(year: year)
          end
        end
      end

      def decade_ranges
        return [] if @artworks.blank?

        earliest_year = @earliest_year || Date.current.year
        current_year = Date.current.year

        start_decade = (earliest_year / 50) * 50

        decades = []
        (start_decade..current_year).step(50) do |year|
          decade_start = year
          decade_end = [year + 49, current_year].min
          decades << ["#{decade_start}-#{decade_end}", "#{decade_start}-#{decade_end}"]
        end

        decades.reverse
      end
      helper_method :decade_ranges
    end
  end
end
