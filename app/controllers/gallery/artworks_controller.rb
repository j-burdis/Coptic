module Gallery
  class ArtworksController < ApplicationController
    before_action :set_base_query, only: [
      :paintings, :prints, :indian_leaves, :indian_waves, 
      :quantel_paintbox, :memories_of_bombay_mumbai, :other,
      :missing_works, :destroyed, :design, :design_subcategory, :all
    ]

    def index
      # load pages for gallery categories
      @gallery_categories = CategoryPage.published
                                        .gallery_category
                                        .ordered

      # Load special collections
      @special_collections = CategoryPage.published
                                         .special_collection
                                         .ordered

      # Fallback: if no category pages exist, show defaults
      if @gallery_categories.empty?
        @categories = {
          paintings: Artwork.published.main_collection.paintings.count,
          prints: Artwork.published.main_collection.prints.count,
          design: Artwork.published.main_collection.design.count,
          indian_leaves: Artwork.published.main_collection.indian_leaves.count,
          indian_waves: Artwork.published.main_collection.indian_waves.count,
          quantel_paintbox: Artwork.published.main_collection.quantel_paintbox.count,
          memories_of_bombay_mumbai: Artwork.published.main_collection.memories_of_bombay_mumbai.count,
          other: Artwork.published.main_collection.other.count
        }
      end

      if @special_collections.empty?
        @special_collections_fallback = {
          missing_works: Artwork.published.main_collection.status_missing.count,
          destroyed: Artwork.published.main_collection.status_destroyed.count
        }
      end
    end

    def paintings
      @category_page = CategoryPage.published.gallery_category.find_by(slug: 'paintings')
      @artworks = @artworks.paintings
      @category_title = "Paintings"
      @show_date_filter = true
      apply_search_and_date_filters
      @artworks = @artworks.page(params[:page]).per(12)
      render :index
    end

    def prints
      @category_page = CategoryPage.published.gallery_category.find_by(slug: 'prints')
      @artworks = @artworks.prints
      @category_title = "Prints"
      @show_date_filter = true
      apply_search_and_date_filters
      @artworks = @artworks.page(params[:page]).per(12)
      render :index
    end

    def indian_leaves
      @category_page = CategoryPage.published.gallery_category.find_by(slug: 'indian-leaves')
      @artworks = @artworks.indian_leaves.page(params[:page]).per(12)
      @category_title = "Indian Leaves"
      @show_date_filter = false
      @fixed_year = "1978"
      render :index
    end

    def indian_waves
      @category_page = CategoryPage.published.gallery_category.find_by(slug: 'indian-waves')
      @artworks = @artworks.indian_waves.page(params[:page]).per(12)
      @category_title = "Indian Waves"
      @show_date_filter = false
      @fixed_year = "1990-1991"
      render :index
    end

    def quantel_paintbox
      @category_page = CategoryPage.published.gallery_category.find_by(slug: 'quantel-paintbox')
      @artworks = @artworks.quantel_paintbox.page(params[:page]).per(12)
      @category_title = "Quantel Paintbox"
      @show_date_filter = false
      @fixed_year = "1986"
      render :index
    end

    def memories_of_bombay_mumbai
      @category_page = CategoryPage.published.gallery_category.find_by(slug: 'memories-of-bombay-mumbai')
      @artworks = @artworks.memories_of_bombay_mumbai
      @category_title = "Memories of Bombay / Mumbai"
      @show_date_filter = true
      apply_search_and_date_filters
      @artworks = @artworks.page(params[:page]).per(12)
      render :index
    end

    def other
      @category_page = CategoryPage.published.gallery_category.find_by(slug: 'other')
      @artworks = @artworks.other
      @category_title = "Other"
      @show_date_filter = true
      apply_search_and_date_filters
      @artworks = @artworks.page(params[:page]).per(12)
      render :index
    end

    def missing_works
      @category_page = CategoryPage.published.special_collection.find_by(slug: 'missing-works')
      @artworks = @artworks.status_missing
      @category_title = "Missing Works"
      @show_date_filter = true
      @status_filter = "missing"
      apply_search_and_date_filters
      @artworks = @artworks.page(params[:page]).per(12)
      render :index
    end

    def destroyed
      @category_page = CategoryPage.published.special_collection.find_by(slug: 'destroyed')
      @artworks = @artworks.status_destroyed.page(params[:page]).per(12)
      @category_title = "Destroyed"
      @show_date_filter = false
      @fixed_year = "1961 or 1962"
      @status_filter = "destroyed"
      render :index
    end

    def design
      @artworks = @artworks.design
      @category_title = "Design"
      @show_design_layout = true
      @design_subcategories = Artwork::DESIGN_SUBCATEGORIES

      # load page for design landing
      @category_page = CategoryPage.published.gallery_category.find_by(slug: 'design')

      # load subcategory pages
      @design_subcategory_pages = CategoryPage.published
                                              .design_subcategory
                                              .ordered
                                              .index_by(&:slug)

      # if subcategory/search is active, show regular layout with filters
      if params[:subcategory].present? || params[:s].present? || params[:dates].present?
        @show_design_layout = false

        if params[:subcategory].present?
          @artworks = @artworks.where(subcategory: params[:subcategory])
          @active_subcategory = params[:subcategory]
          @subcategory_page = @design_subcategory_pages[params[:subcategory]]
        end

        # apply search and date filters
        apply_search_and_date_filters

        # paginate
        @artworks = @artworks.page(params[:page]).per(12)
      end

      @show_date_filter = true
    end

    def design_subcategory
      @category_page = CategoryPage.published.design_subcategory.find_by(slug: params[:subcategory])
      @artworks = @artworks.design.where(subcategory: params[:subcategory])
      @category_title = "Design - #{params[:subcategory].titleize}"
      @show_date_filter = true
      @design_subcategories = Artwork::DESIGN_SUBCATEGORIES
      @active_subcategory = params[:subcategory]
      apply_search_and_date_filters
      @artworks = @artworks.page(params[:page]).per(12)
      render :index
    end

    def all
      @category_title = "All Artworks"
      @show_date_filter = true
      apply_search_and_date_filters
      @artworks = @artworks.page(params[:page]).per(12)
      render :index
    end

    private

    def set_base_query
      @artworks = Artwork.published.main_collection.order(year: :desc, title: :asc)
    end

    def apply_search_and_date_filters
      # keyword search
      if params[:s].present?
        search_term = "%#{params[:s]}%"
        @artworks = @artworks.where(
          "title ILIKE ? OR description ILIKE ? OR medium ILIKE ?", 
          search_term, search_term, search_term
        )
      end

      # date range filter
      if params[:dates].present?
        case params[:dates]
        when /(\d{4})-(\d{4})/ # decade range
          start_year = $1.to_i
          end_year = $2.to_i
          @artworks = @artworks.where("year >= ? AND year <= ?", start_year, end_year)
        when /(\d{4})/ # single year
          year = $1.to_i
          @artworks = @artworks.where(year: year)
        end
      end
    end

    def decade_ranges
      current_year = Date.current.year
      start_decade = 1960

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
end
