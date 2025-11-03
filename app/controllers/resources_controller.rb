class ResourcesController < ApplicationController
  def show
    @artwork = Artwork.find_by(slug: params[:slug])
  end
end
