class AddImageCaptionToResources < ActiveRecord::Migration[7.2]
  def change
    add_column :resources, :image_caption, :text
  end
end
