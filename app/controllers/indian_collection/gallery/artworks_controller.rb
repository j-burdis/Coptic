module IndianCollection
  module Gallery
    class ArtworksController < ApplicationController
      layout 'indian_collection'

      before_action :set_base_query, only: [:index, :portrait, :elephants, :flora_fauna]
      before_action :load_category_pages

      def index
        @category_title = "Indian Collection"
        @show_date_filter = true

        @earliest_year = @artworks.minimum(:year)
        @latest_year = @artworks.maximum(:year)
        @fuzzy_latest_year = @artworks.where(year: nil).where.not(date_display: nil)
                                      .filter_map { |a| resolve_date_display(a.date_display) }
                                      .max

        apply_search_and_date_filters
        @artworks = @artworks.sort_by { |a| [-sort_year_for(a), a.title] }
        @artworks = Kaminari.paginate_array(
          @artworks.sort_by { |a| [-sort_year_for(a), a.title] }
        ).page(params[:page]).per(12)
      end

      def portrait
        @category_page = CategoryPage.published.indian_collection_gallery_category.find_by(slug: 'portrait')
        @artworks = @artworks.where(indian_collection_category: 'portrait')
        @category_title = "Portrait"
        @show_date_filter = true

        @earliest_year = @artworks.minimum(:year)
        @latest_year = @artworks.maximum(:year)
        @fuzzy_latest_year = @artworks.where(year: nil).where.not(date_display: nil)
                                      .filter_map { |a| resolve_date_display(a.date_display) }
                                      .max

        apply_search_and_date_filters
        @artworks = @artworks.sort_by { |a| [-sort_year_for(a), a.title] }
        @artworks = Kaminari.paginate_array(
          @artworks.sort_by { |a| [-sort_year_for(a), a.title] }
        ).page(params[:page]).per(12)
        render :index
      end

      def elephants
        @category_page = CategoryPage.published.indian_collection_gallery_category.find_by(slug: 'elephants')
        @artworks = @artworks.where(indian_collection_category: 'elephants')
        @category_title = "Elephants"
        @show_date_filter = true

        @earliest_year = @artworks.minimum(:year)
        @latest_year = @artworks.maximum(:year)
        @fuzzy_latest_year = @artworks.where(year: nil).where.not(date_display: nil)
                                      .filter_map { |a| resolve_date_display(a.date_display) }
                                      .max

        apply_search_and_date_filters
        @artworks = @artworks.sort_by { |a| [-sort_year_for(a), a.title] }
        @artworks = Kaminari.paginate_array(
          @artworks.sort_by { |a| [-sort_year_for(a), a.title] }
        ).page(params[:page]).per(12)
        render :index
      end

      def flora_fauna
        @category_page = CategoryPage.published.indian_collection_gallery_category.find_by(slug: 'flora-fauna')
        @artworks = @artworks.where(indian_collection_category: 'flora_fauna')
        @category_title = "Flora & Fauna"
        @show_date_filter = true

        @earliest_year = @artworks.minimum(:year)
        @latest_year = @artworks.maximum(:year)
        @fuzzy_latest_year = @artworks.where(year: nil).where.not(date_display: nil)
                                      .filter_map { |a| resolve_date_display(a.date_display) }
                                      .max

        apply_search_and_date_filters
        @artworks = @artworks.sort_by { |a| [-sort_year_for(a), a.title] }
        @artworks = Kaminari.paginate_array(
          @artworks.sort_by { |a| [-sort_year_for(a), a.title] }
        ).page(params[:page]).per(12)
        render :index
      end

      private

      def set_base_query
        @artworks = Artwork.published.indian_collection
      end

      def sort_year_for(artwork)
        return artwork.year if artwork.year.present?
        return resolve_date_display(artwork.date_display) if artwork.date_display.present?

        0
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

            numeric_ids = @artworks.where(
              "(year >= ? AND year <= ?) OR (year_end >= ? AND year_end <= ?) OR (year <= ? AND year_end >= ?)",
              start_year, end_year, start_year, end_year, start_year, end_year
            ).pluck(:id)

            fuzzy_ids = @artworks.where(year: nil).where.not(date_display: nil).select do |artwork|
              resolved = resolve_date_display(artwork.date_display)
              resolved && resolved >= start_year && resolved <= end_year
            end.map(&:id)

            @artworks = @artworks.where(id: numeric_ids + fuzzy_ids)

          when /(\d{4})/
            year = $1.to_i
            @artworks = @artworks.where(year: year)
          end
        end
      end

      def resolve_date_display(date_display)
        return nil if date_display.blank?

        text = date_display.downcase.strip

        # extract a 4-digit year if present (e.g. "c. 1650", "1645-1650")
        if text =~ /(\d{4})/
          return $1.to_i
        end

        # map century phrases to approximate midpoints
        century_map = {
          'early'  => 15,
          'mid'    => 50,
          'middle' => 50,
          'late'   => 85
        }

        if text =~ /(early|mid|middle|late)[\s\-]*(\d{1,2})(?:st|nd|rd|th)\s+century/i
          modifier = $1.downcase
          century  = $2.to_i
          offset   = century_map[modifier] || 50
          return (century - 1) * 100 + offset
        end

        if text =~ /(\d{1,2})(?:st|nd|rd|th)\s+century/i
          century = $1.to_i
          return (century - 1) * 100 + 50
        end

        nil
      end

      def decade_ranges
        return [] if @artworks.blank?

        earliest_year = @earliest_year || 1500
        latest_year = [@latest_year, @fuzzy_latest_year].compact.max || 1900

        start_decade = (earliest_year / 50) * 50
        end_decade = (latest_year / 50) * 50

        decades = []
        (start_decade..end_decade).step(50) do |year|
          decade_start = year
          decade_end = year + 49
          decades << ["#{decade_start}-#{decade_end}", "#{decade_start}-#{decade_end}"]
        end

        decades.reverse
      end
      helper_method :decade_ranges
    end
  end
end
