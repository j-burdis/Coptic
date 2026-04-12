class AddSecondaryWebsitesToContacts < ActiveRecord::Migration[7.2]
  def change
    add_column :contacts, :secondary_websites, :text
  end
end
