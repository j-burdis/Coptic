module Gallery
  class ArtworksController < ApplicationController
    def index
      @artworks = Artwork.all
      # Add default filtering logic
    end

    def paintings
      @artworks = Artwork.where(category: 'painting', is_indian_collection: false)
      render :index
    end

    def prints
      @artworks = Artwork.where(category: 'print', is_indian_collection: false)
      render :index
    end

    def indian_leaves
      @artworks = Artwork.where(category: 'indian_leaves', is_indian_collection: false)
      render :index
    end

    def indian_waves
      @artworks = Artwork.where(category: 'indian_waves', is_indian_collection: false)
      render :index
    end

    def quantel_paintbox
      @artworks = Artwork.where(category: 'quantel_paintbox', is_indian_collection: false)
      render :index
    end

    def memories_of_bombay_mumbai
      @artworks = Artwork.where(category: 'memories_of_bombay_mumbai', is_indian_collection: false)
      render :index
    end

    def other
      @artworks = Artwork.where(category: 'other', is_indian_collection: false)
      render :index
    end

    def missing_works
      @artworks = Artwork.where(status: 'missing', is_indian_collection: false)
      render :index
    end

    def destroyed
      @artworks = Artwork.where(status: 'destroyed', is_indian_collection: false)
      render :index
    end

    def design
      @artworks = Artwork.where(category: 'design', is_indian_collection: false)
      # needs special handling
      render :design
    end

    def design_subcategory
      @artworks = Artwork.where(category: 'design', subcategory: params[:subcategory])
      render :index
    end

    def all
      @artworks = Artwork.all
      render :index
    end
  end
end
