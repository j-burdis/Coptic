class AddImageCaptionToNewsItems < ActiveRecord::Migration[7.2]
  def change
    add_column :news_items, :image_caption, :text
  end
end
