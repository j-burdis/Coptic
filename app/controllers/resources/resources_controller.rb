module Resources
  class ResourcesController < ApplicationController
    def index
      @resources = Resource.all
    end

    def films_and_audio
      @resources = Resource.where(category: 'films_and_audio', is_indian_collection: false)
      render :index
    end

    def texts
      @resources = Resource.where(category: 'texts', is_indian_collection: false)
      render :index
    end

    def texts_subcategory
      @resources = Resource.where(category: 'texts', subcategory: params[:subcategory], is_indian_collection: false)
      render :index
    end

    def publications
      @resources = Resource.where(category: 'publications', is_indian_collection: false)
      render :index
    end

    def publications_subcategory
      @resources = Resource.where(category: 'publications',
                                  subcategory: params[:subcategory], is_indian_collection: false)
      render :index
    end

    def chronology
      @resources = Resource.where(category: 'chronology')
      render :index
    end

    def show
      @resource = Resource.find_by(slug: params[:slug])
    end
  end
end
