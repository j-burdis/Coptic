class CreateArtworkRelations < ActiveRecord::Migration[7.2]
  def change
    create_table :artwork_relations do |t|
      t.references :artwork, null: false, foreign_key: true
      t.integer :related_artwork_id
      t.integer :position

      t.timestamps
    end

    add_index :artwork_relations, :related_artwork_id
    add_index :artwork_relations, [:artwork_id, :related_artwork_id], 
              unique: true,
              name: 'index_artwork_relations_on_artwork_and_related'
    add_foreign_key :artwork_relations, :artworks, column: :related_artwork_id
  end
end
