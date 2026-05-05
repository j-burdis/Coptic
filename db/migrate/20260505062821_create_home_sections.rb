class CreateHomeSections < ActiveRecord::Migration[7.2]
  def change
    create_table :home_sections do |t|
      t.string :title
      t.text :description
      t.string :image_cloudinary_public_id
      t.string :image_original_filename
      t.string :image_caption
      t.string :link_url
      t.string :link_text
      t.string :video_url
      t.string :layout
      t.integer :position
      t.boolean :published

      t.timestamps
    end
  end
end
