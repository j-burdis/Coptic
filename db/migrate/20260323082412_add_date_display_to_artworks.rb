class AddDateDisplayToArtworks < ActiveRecord::Migration[7.2]
  def change
    add_column :artworks, :date_display, :string
    add_index :artworks, :date_display
  end
end
