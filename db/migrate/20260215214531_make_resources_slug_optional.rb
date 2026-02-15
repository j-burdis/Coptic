class MakeResourcesSlugOptional < ActiveRecord::Migration[7.2]
  def change
    change_column_null :resources, :slug, true
  end
end
