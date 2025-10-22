class CreatePages < ActiveRecord::Migration[7.2]
  def change
    create_table :pages do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :content
      t.boolean :published, null: false, default: true

      t.timestamps
    end
    add_index :pages, :title
    add_index :pages, :slug, unique: true
    add_index :pages, :published
  end
end
