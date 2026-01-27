ActiveAdmin.register Quote do
  menu priority: 4, label: "Quotes"

  permit_params :title, :text, :author, :source, :page_location, :position, :published

  index do
    selectable_column
    id_column
    column :title
    column :page_location do |quote|
      status_tag quote.page_location.titleize
    end
    column :text do |quote|
      truncate(quote.text, length: 60)
    end
    column :author
    column :position
    column :published do |quote|
      status_tag(quote.published ? 'Yes' : 'No',
                 class: (quote.published ? 'yes' : 'no'))
    end
    actions
  end

  filter :title
  filter :page_location, as: :select, collection: Quote.page_locations
  filter :author
  filter :published

  form do |f|
    f.inputs "Quote Details" do
      f.input :title, 
              hint: "Internal reference (e.g., 'Gallery Landing Quote')"
      
      f.input :page_location, 
              as: :select, 
              collection: Quote.page_locations,
              hint: "Where should this quote appear?"
      
      f.input :position,
              hint: "Order on page (lower numbers appear first)"
      
      f.input :published
    end

    f.inputs "Quote Content" do
      f.input :text, 
              as: :text,
              input_html: { rows: 4 },
              hint: "The quote text (without quotation marks)"
      
      f.input :author, 
              hint: "Who said it or attribution (e.g., '— Howard Hodgkin')"
      
      f.input :source, 
              as: :text,
              input_html: { rows: 2 },
              hint: "Source citation (optional)"
    end
    
    f.actions
  end

  show do
    attributes_table do
      row :title
      row :page_location do |quote|
        status_tag quote.page_location.titleize
      end
      row :position
      row :published do |quote|
        status_tag(quote.published ? 'Yes' : 'No',
                   class: (quote.published ? 'yes' : 'no'))
      end
      row :text do |quote|
        simple_format(quote.text)
      end
      row :author
      row :source do |quote|
        simple_format(quote.source) if quote.source.present?
      end
      row :created_at
      row :updated_at
    end
    
    panel "Preview" do
      div class: "quote-preview", style: "padding: 20px; background: #f5f5f5; border-left: 4px solid #333;" do
        para quote.text, style: "font-style: italic; font-size: 18px; margin-bottom: 10px;"
        para quote.author, style: "font-weight: bold;"
        para quote.source, style: "font-size: 14px; color: #666;" if quote.source.present?
      end
    end
  end
end
