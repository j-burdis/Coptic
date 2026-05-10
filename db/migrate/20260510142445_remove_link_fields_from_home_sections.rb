class RemoveLinkFieldsFromHomeSections < ActiveRecord::Migration[7.2]
  def change
    remove_column :home_sections, :link_url, :string
    remove_column :home_sections, :link_text, :string
  end
end
