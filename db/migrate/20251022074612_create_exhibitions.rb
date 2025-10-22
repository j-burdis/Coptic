class CreateExhibitions < ActiveRecord::Migration[7.2]
  def change
    create_table :exhibitions do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.integer :year
      t.integer :year_end
      t.string :venue
      t.string :location
      t.text :description
      t.integer :exhibition_type, null: false, default: 0
      t.boolean :is_indian_collection, null: false, default: false
      t.boolean :published, null: false, default: true

      t.timestamps
    end

    add_index :exhibitions, :title
    add_index :exhibitions, :slug, unique: true
    add_index :exhibitions, :year
    add_index :exhibitions, :exhibition_type
    add_index :exhibitions, :is_indian_collection
    add_index :exhibitions, :published
  end
end
