class AddYearToCategoryPages < ActiveRecord::Migration[7.2]
  def change
    add_column :category_pages, :year, :integer
    add_index :category_pages, :year
  end
end
