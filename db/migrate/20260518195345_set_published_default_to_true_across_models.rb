class SetPublishedDefaultToTrueAcrossModels < ActiveRecord::Migration[7.2]
  def change
    change_column_default :carousel_slides, :published, from: nil, to: true
    change_column_default :collections,     :published, from: nil, to: true
    change_column_default :home_sections,   :published, from: nil, to: true
    change_column_default :contacts,        :published, from: nil, to: true
    change_column_default :quotes,          :published, from: nil, to: true
    change_column_default :indian_collection_exhibition_lists, :published, from: false, to: true
  end
end
