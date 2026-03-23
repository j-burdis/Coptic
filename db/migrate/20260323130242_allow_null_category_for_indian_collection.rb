class AllowNullCategoryForIndianCollection < ActiveRecord::Migration[7.2]
  def change
    change_column_null :artworks, :category, true
    change_column_default :artworks, :category, from: 0, to: nil
  end
end
