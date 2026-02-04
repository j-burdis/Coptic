class AddCloudinaryToExhibitions < ActiveRecord::Migration[7.2]
  def change
    add_column :exhibitions, :cloudinary_public_id, :string
    add_column :exhibitions, :original_filename, :string
  end
end
