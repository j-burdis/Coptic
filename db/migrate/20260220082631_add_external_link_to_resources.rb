class AddExternalLinkToResources < ActiveRecord::Migration[7.2]
  def change
    add_column :resources, :external_link, :string
  end
end
