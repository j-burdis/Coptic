class AddExternalUrlToNewsItems < ActiveRecord::Migration[7.2]
  def change
    add_column :news_items, :external_url, :string
  end
end
