class AddPublisherToResources < ActiveRecord::Migration[7.2]
  def change
    add_column :resources, :publisher, :string
  end
end
