class CreateArtworkExhibitions < ActiveRecord::Migration[7.2]
  def change
    create_table :artwork_exhibitions do |t|
      t.references :artwork, null: false, foreign_key: true
      t.references :exhibition, null: false, foreign_key: true

      t.timestamps
    end

    add_index :artwork_exhibitions, [:artwork_id, :exhibition_id], 
              unique: true,
              name: 'index_artwork_exhibitions_on_artwork_and_exhibition'
  end
end
