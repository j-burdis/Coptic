class RemoveLegacyImageFieldsFromExhibitions < ActiveRecord::Migration[7.2]
  def change
    remove_column :exhibitions, :cloudinary_public_id, :string
    remove_column :exhibitions, :original_filename, :string
    remove_column :exhibitions, :image_caption, :text
  end
end
