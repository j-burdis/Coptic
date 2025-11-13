class CreateCategoryPages < ActiveRecord::Migration[7.2]
  def change
    create_table :category_pages do |t|
      t.string :slug, null: false
      t.string :title, null: false
      t.text :description
      t.string :cloudinary_public_id
      t.string :original_filename
      t.integer :page_type, default: 0, null: false
      t.integer :position, default: 0
      t.boolean :published, default: true, null: false

      t.timestamps
    end

    add_index :category_pages, :slug, unique: true
    add_index :category_pages, :page_type
    add_index :category_pages, :published
    add_index :category_pages, :position
  end
end
