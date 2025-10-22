class CreateArtworks < ActiveRecord::Migration[7.2]
  def change
    create_table :artworks do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.integer :year
      t.integer :year_end
      t.string :medium
      t.text :description
      t.string :dimensions
      t.integer :category, null: false, default: 0
      t.string :subcategory
      t.integer :status, null: false, default: 0
      t.boolean :published, null: false, default: true
      t.boolean :is_indian_collection, null: false, default: false
      t.string :indian_collection_category
      t.string :cloudinary_public_id
      t.string :original_filename

      t.timestamps
    end

    add_index :artworks, :slug, unique: true
    add_index :artworks, :year
    add_index :artworks, :category
    add_index :artworks, :subcategory
    add_index :artworks, :status
    add_index :artworks, :published
    add_index :artworks, :is_indian_collection
  end
end
