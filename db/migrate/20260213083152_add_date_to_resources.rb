class AddDateToResources < ActiveRecord::Migration[7.2]
  def change
    add_column :resources, :date, :date
  end
end
