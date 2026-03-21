module IndianCollection
  class PagesController < ApplicationController
    def index
      @show_landing = true

      @indian_collection_categories = CategoryPage.published
                                                  .indian_collection_category
                                                  .ordered

      @indian_collection_quote = Quote.indian_collection_landing.published.first

      if @indian_collection_categories.empty?
        @categories_fallback = {
          gallery: Artwork.published.indian_collection.count,
          resources: Resource.published.indian_collection.count,
          exhibitions: "Exhibition List"
        }
      end
    end
  end
end
