module IndianCollection
  module Gallery
    class ArtworksController < ApplicationController
      def index
        @artworks = Artwork.where(is_indian_collection: true)
      end

      def portrait
        @artworks = Artwork.where(is_indian_collection: true, indian_collection_category: 'portrait')
        render :index
      end

      def elephants
        @artworks = Artwork.where(is_indian_collection: true, indian_collection_category: 'elephants')
        render :index
      end

      def flora_fauna
        @artworks = Artwork.where(is_indian_collection: true, indian_collection_category: 'flora_fauna')
        render :index
      end
    end
  end
end
