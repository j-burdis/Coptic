class RemoveLegacyImageFieldsFromResources < ActiveRecord::Migration[7.2]
  def change
    remove_column :resources, :cloudinary_public_id, :string
    remove_column :resources, :original_filename, :string
    remove_column :resources, :image_caption, :text
  end
end
