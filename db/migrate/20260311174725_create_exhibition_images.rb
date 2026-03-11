class CreateExhibitionImages < ActiveRecord::Migration[7.2]
  def change
    create_table :exhibition_images do |t|
      t.references :exhibition, null: false, foreign_key: true
      t.string :cloudinary_public_id, null: false
      t.string :original_filename
      t.text :caption
      t.integer :position, default: 0, null:false

      t.timestamps
    end

    add_index :exhibition_images, [:exhibition_id, :position]
  end
end
