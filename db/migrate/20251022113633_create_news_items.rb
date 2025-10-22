class CreateNewsItems < ActiveRecord::Migration[7.2]
  def change
    create_table :news_items do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :content
      t.text :excerpt
      t.datetime :published_at
      t.boolean :published, null: false, default: true
      t.string :cloudinary_public_id

      t.timestamps
    end
    add_index :news_items, :title
    add_index :news_items, :slug, unique: true
    add_index :news_items, :published_at
    add_index :news_items, :published
  end
end
