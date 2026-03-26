class AddExternalUrlToArtworks < ActiveRecord::Migration[7.2]
  def change
    add_column :artworks, :external_url, :string
  end
end
