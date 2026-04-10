class CreateContacts < ActiveRecord::Migration[7.2]
  def change
    create_table :contacts do |t|
      t.string :name
      t.string :category
      t.text :address
      t.string :phone
      t.string :fax
      t.string :email
      t.string :website
      t.integer :position
      t.boolean :published

      t.timestamps
    end
  end
end
