class FixCollectionsIndexes < ActiveRecord::Migration[7.2]
  def change
    remove_index :collections, :name
    add_index :collections, :name
    
    add_index :collections, :region
    add_index :collections, :published
  end
end
