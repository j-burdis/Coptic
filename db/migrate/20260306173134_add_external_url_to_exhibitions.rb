class AddExternalUrlToExhibitions < ActiveRecord::Migration[7.2]
  def change
    add_column :exhibitions, :external_url, :string
  end
end
