class CreateCollections < ActiveRecord::Migration[7.2]
  def change
    create_table :collections do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :location
      t.string :region
      t.text :description
      t.string :website
      t.boolean :published, null: false, default: true

      t.timestamps
    end
    add_index :collections, :name, unique: true
    add_index :collections, :slug, unique: true
  end
end
