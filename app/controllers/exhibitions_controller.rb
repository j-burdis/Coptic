class ExhibitionsController < ApplicationController
  def show
    @exhibition = Exhibition.find_by!(slug: params[:slug])
    @artworks = @exhibition.artworks.published.order(year: :desc, title: :asc)
  end
end
