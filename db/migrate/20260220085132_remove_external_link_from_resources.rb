class RemoveExternalLinkFromResources < ActiveRecord::Migration[7.2]
  def change
    remove_column :resources, :external_link, :string
  end
end
