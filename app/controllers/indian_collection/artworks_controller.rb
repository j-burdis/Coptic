class IndianCollection::ArtworksController < ApplicationController
  layout 'indian_collection'

  def show
    @artwork = Artwork.published.indian_collection.find_by!(slug: params[:slug])
  rescue ActiveRecord::RecordNotFound
    redirect_to indian_collection_gallery_root_path, alert: "Artwork not found"
  end
end
