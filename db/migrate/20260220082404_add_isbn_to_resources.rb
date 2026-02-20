class AddIsbnToResources < ActiveRecord::Migration[7.2]
  def change
    add_column :resources, :isbn, :string
  end
end
