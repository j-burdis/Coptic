class AddShowDayToResources < ActiveRecord::Migration[7.2]
  def change
    add_column :resources, :show_day, :boolean
  end
end
