class ResourcesController < ApplicationController
  def show
    @resource = Resource.find_by!(slug: params[:slug])
    # For breadcrumbs and navigation
    @category_title = @resource.category.titleize
  end
end
