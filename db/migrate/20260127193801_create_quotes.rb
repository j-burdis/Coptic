class CreateQuotes < ActiveRecord::Migration[7.2]
  def change
    create_table :quotes do |t|
      t.string :title
      t.text :text
      t.string :author
      t.text :source
      t.string :page_location
      t.integer :position
      t.boolean :published

      t.timestamps
    end
  end
end
