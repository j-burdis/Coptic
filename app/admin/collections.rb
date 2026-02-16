ActiveAdmin.register Collection do
  permit_params :name, :slug, :location, :region, :description, :website, :published
end

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :name, :slug, :location, :region, :description, :website, :published
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :slug, :location, :region, :description, :website, :published]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end