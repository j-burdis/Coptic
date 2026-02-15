class AddYearEndToResources < ActiveRecord::Migration[7.2]
  def change
    add_column :resources, :year_end, :integer
  end
end
