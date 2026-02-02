class CollectionsController < ApplicationController
  def show
    @collection = Collection.find_by!(slug: params[:slug])
    @artworks = @collection.artworks.published.order(year: :desc, title: :asc).page(params[:page]).per(12)

    # For breadcrumbs
    @category_title = "Collections"
  end
end
