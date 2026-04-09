class AddOriginalFilenameToNewsItems < ActiveRecord::Migration[7.2]
  def change
    add_column :news_items, :original_filename, :string
  end
end
