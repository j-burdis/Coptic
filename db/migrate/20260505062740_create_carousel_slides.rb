class CreateCarouselSlides < ActiveRecord::Migration[7.2]
  def change
    create_table :carousel_slides do |t|
      t.bigint :artwork_id
      t.string :cloudinary_public_id
      t.string :original_filename
      t.text :quote_text
      t.string :quote_attribution
      t.integer :position
      t.boolean :published

      t.timestamps
    end
  end
end
