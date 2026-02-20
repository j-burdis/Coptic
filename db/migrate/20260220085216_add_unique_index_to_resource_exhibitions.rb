class AddUniqueIndexToResourceExhibitions < ActiveRecord::Migration[7.2]
  def change
    add_index :resource_exhibitions, [:resource_id, :exhibition_id], 
              unique: true, 
              name: 'index_resource_exhibitions_on_resource_and_exhibition'
  end
end
