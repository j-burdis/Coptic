ActiveAdmin.register Page do
  permit_params :title, :slug, :content, :published

  index do
    selectable_column
    id_column
    column :title
    column :slug
    column :published do |page|
      status_tag(page.published ? 'Yes' : 'No', class: (page.published ? 'yes' : 'no'))
    end
    actions
  end

  filter :title
  filter :slug
  filter :published

  show do
    attributes_table do
      row :title
      row :slug
      row :published
      row :content do |page|
        div do
          raw page.content
        end
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors

    f.inputs "Basic Information" do
      f.input :title
      f.input :slug, hint: 'Leave blank to auto-generate from title'
      f.input :published
    end

    f.inputs "Content" do
      f.input :content,
              as: :text,
              input_html: { rows: 20 },
              hint: 'HTML is supported. Use &lt;p&gt; for paragraphs, &lt;a href=""&gt; for links, &lt;strong&gt; for bold.'
    end

    f.actions
  end
end
