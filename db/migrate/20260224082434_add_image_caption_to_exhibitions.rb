class AddImageCaptionToExhibitions < ActiveRecord::Migration[7.2]
  def change
    add_column :exhibitions, :image_caption, :text
  end
end
