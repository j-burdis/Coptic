class AddDateToNewsItems < ActiveRecord::Migration[7.2]
  def change
    add_column :news_items, :date, :date
  end
end
