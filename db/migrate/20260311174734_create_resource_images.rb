class CreateResourceImages < ActiveRecord::Migration[7.2]
  def change
    create_table :resource_images do |t|
      t.references :resource, null: false, foreign_key: true
      t.string :cloudinary_public_id, null: false
      t.string :original_filename
      t.text :caption
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :resource_images, [:resource_id, :position]
  end
end
