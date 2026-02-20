class CreateResourceExhibitions < ActiveRecord::Migration[7.2]
  def change
    create_table :resource_exhibitions do |t|
      t.references :resource, null: false, foreign_key: true
      t.references :exhibition, null: false, foreign_key: true

      t.timestamps
    end
  end
end
