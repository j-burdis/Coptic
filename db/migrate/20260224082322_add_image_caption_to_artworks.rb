class AddImageCaptionToArtworks < ActiveRecord::Migration[7.2]
  def change
    add_column :artworks, :image_caption, :text
  end
end
