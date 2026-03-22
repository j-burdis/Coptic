ActiveAdmin.register IndianCollectionExhibitionList do
  menu priority: 8, label: "IC Exhibition List", parent: "Indian Collection"

  permit_params :content, :published

  index do
    selectable_column
    id_column
    column :published
    column :created_at
    column :updated_at
    actions
  end

  filter :published
  filter :created_at

  form do |f|
    f.semantic_errors

    f.inputs "Exhibition List Content" do
      f.input :content,
              as: :text,
              input_html: { rows: 30 },
              hint: "Paste the full HTML content here. Use <b>Decade</b> for bold headings, <ul><li>...</li></ul> for lists, <i>Title</i> for italics."
      
      f.input :published
    end

    f.actions
  end

  show do
    attributes_table do
      row :published
      row :created_at
      row :updated_at
      row :content do |list|
        raw list.content
      end
    end
  end
end