ActiveAdmin.register Collection do
  permit_params :name, :slug, :location, :region, :description, :website, :published

  filter :name
  filter :location
  filter :region

  form do |f|
    f.semantic_errors

    columns do
      column do
        f.inputs "Collection details" do
          f.input :name
          f.input :slug
          f.input :location
          f.input :region
          f.input :website
          f.input :published
        end
      end

      column do
        f.inputs "Additional details" do
          f.input :description,
                  as: :text,
                  input_html: { rows: 6 }
        end
      end
    end
    f.actions
  end

  index do
    selectable_column
    id_column
  
    column :name
    column :location
    column :region
    column :website
    actions
  end

  show do
    columns do
      column do
        panel "Details" do
          attributes_table_for collection do
            row :name
            row :slug
            row :location
            row :region
            row :website
            row :published do
              status_tag(collection.published ? 'Yes' : 'No', class: (collection.published ? 'yes' : 'no'))
            end
          end
        end
      end

      column do
        panel "Description" do
          attributes_table_for collection do
            row :description
            row :created_at
            row :updated_at
          end
        end
      end
    end
  end
end
