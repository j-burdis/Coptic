class RemoveContentFromResources < ActiveRecord::Migration[7.2]
  def change
    remove_column :resources, :content, :text
  end
end
