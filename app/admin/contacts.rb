ActiveAdmin.register Contact do
  permit_params :name, :category, :address, :phone, :fax, :email, 
                :website, :position, :published

  index do
    selectable_column
    id_column
    column :name
    column :category
    column :position
    column :published do |contact|
      status_tag(contact.published ? 'Yes' : 'No', class: (contact.published ? 'yes' : 'no'))
    end
    actions
  end

  filter :name
  filter :category, as: :select, collection: Contact::CATEGORIES
  filter :published

  form do |f|
    f.semantic_errors

    columns do
      column do
        f.inputs "Basic Information" do
          f.input :name
          f.input :category,
                  as: :select,
                  collection: Contact::CATEGORIES,
                  include_blank: false
          f.input :published
          f.input :position, hint: 'Controls display order within each category'
        end
      end

      column do
        f.inputs "Contact Details" do
          f.input :address, as: :text, input_html: { rows: 3 }
          f.input :phone
          f.input :fax
          f.input :email
          f.input :website
        end
      end
    end

    f.actions
  end

  show do
    attributes_table do
      row :name
      row :category
      row :address
      row :phone
      row :fax
      row :email
      row :website do
        if contact.website.present?
          link_to contact.website, contact.website, target: '_blank'
        end
      end
      row :position
      row :published
      row :created_at
      row :updated_at
    end
  end
end