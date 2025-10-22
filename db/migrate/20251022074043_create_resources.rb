class CreateResources < ActiveRecord::Migration[7.2]
  def change
    create_table :resources do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.integer :category, null: false
      t.string :subcategory
      t.integer :year
      t.string :author
      t.text :summary
      t.text :description
      t.text :content
      t.string :external_url
      t.string :cloudinary_public_id
      t.string :original_filename
      t.string :video_type
      t.string :video_id
      t.text :embed_code
      t.integer :duration_seconds
      t.boolean :is_indian_collection, null: false, default: false
      t.boolean :published, null: false, default: true

      t.timestamps
    end

    add_index :resources, :title
    add_index :resources, :slug, unique: true
    add_index :resources, :category
    add_index :resources, :subcategory
    add_index :resources, :year
    add_index :resources, :video_type
    add_index :resources, :is_indian_collection
    add_index :resources, :published
  end
end
