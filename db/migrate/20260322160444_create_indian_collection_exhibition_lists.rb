class CreateIndianCollectionExhibitionLists < ActiveRecord::Migration[7.2]
  def change
    create_table :indian_collection_exhibition_lists do |t|
      t.text :content
      t.boolean :published, default: false, null: false

      t.timestamps
    end

    add_index :indian_collection_exhibition_lists, :published
  end
end
