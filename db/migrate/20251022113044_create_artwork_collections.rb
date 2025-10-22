class CreateArtworkCollections < ActiveRecord::Migration[7.2]
  def change
    create_table :artwork_collections do |t|
      t.references :artwork, null: false, foreign_key: true
      t.references :collection, null: false, foreign_key: true

      t.timestamps
    end

    add_index :artwork_collections, [:artwork_id, :collection_id], 
              unique: true, 
              name: 'index_artwork_collections_on_artwork_and_collection'
  end
end
