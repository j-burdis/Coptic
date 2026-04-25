class AddImageToCollections < ActiveRecord::Migration[7.2]
  def change
    add_column :collections, :cloudinary_public_id, :string
    add_column :collections, :original_filename, :string
  end
end
