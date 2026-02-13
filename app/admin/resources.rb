ActiveAdmin.register Resource do
  permit_params :title, :slug, :category, :subcategory, :year, :date, :author,
                :publisher, :summary, :description, :content, :external_url,
                :video_type, :video_id, :duration_seconds, :is_indian_collection,
                :published, :image, :cloudinary_public_id, :original_filename

  # Sidebar filters
  filter :title
  filter :category, as: :select, collection: -> { Resource.categories.keys }
  filter :subcategory
  filter :year
  filter :author
  filter :published
  filter :created_at

  form do |f|
    columns do
      column do
        panel 'Video' do
          f.inputs do
            f.input :video_type, as: :select, collection: ['youtube', 'vimeo'], include_blank: 'No video'
            f.input :video_id, hint: "For YouTube: the ID from youtube.com/watch?v=VIDEO_ID<br>For Vimeo: the ID from vimeo.com/VIDEO_ID".html_safe
            f.input :duration_seconds, hint: "Video duration in seconds (optional)"
          end
        end
        panel 'Image' do
          f.inputs do
            f.input :image, as: :file, label: 'Upload Image (Thumbnail)', hint: f.object.cloudinary_public_id.present? ? image_tag(f.object.thumbnail_url, style: 'max-width: 100%; display: block; margin-top: 10px;') : content_tag(:span, "No image uploaded")
          end
        end
      end

      column do
        f.inputs 'Resource Details' do
          f.input :title
          f.input :slug
          f.input :category, as: :select, collection: Resource.categories.keys
          f.input :subcategory, as: :select, collection: Resource::TEXT_SUBCATEGORIES + Resource::PUBLICATION_SUBCATEGORIES, include_blank: true

          f.input :date, as: :datepicker, label: 'Date (for Texts - optional)',
                         hint: 'Use for full date (16 May 2024) or month/year (1 May 2024 = May 2024)'
          f.input :year, label: 'Year only (for publications or if no specific date)',
                         hint: 'Use when you only have a year (2024)'

          f.input :author
          f.input :publisher, hint: 'Publisher/source of the text or publication'
          f.input :summary, as: :text
          f.input :description, as: :text, input_html: { rows: 6 }
          f.input :content, as: :text, input_html: { rows: 10 }
          f.input :external_url
          f.input :is_indian_collection
          f.input :published
        end
      end
    end
    f.actions
  end

  controller do
    def create
      @resource = Resource.new(permitted_params[:resource])

      if params[:resource][:image].present?
        uploaded_file = params[:resource][:image]
        result = Cloudinary::Uploader.upload(uploaded_file.tempfile.path, folder: 'resources')
        @resource.cloudinary_public_id = result['public_id']
        @resource.original_filename = uploaded_file.original_filename
      end

      if @resource.save
        redirect_to admin_resource_path(@resource), notice: 'Resource created successfully.'
      else
        render :new
      end
    end

    def update
      @resource = Resource.find(params[:id])

      if params[:resource][:image].present?
        uploaded_file = params[:resource][:image]
        result = Cloudinary::Uploader.upload(uploaded_file.tempfile.path, folder: 'resources')
        @resource.cloudinary_public_id = result['public_id']
        @resource.original_filename = uploaded_file.original_filename
      end

      if @resource.update(permitted_params[:resource])
        redirect_to admin_resource_path(@resource), notice: 'Resource updated successfully.'
      else
        render :edit
      end
    end
  end

  index do
    selectable_column
    id_column

    column :image, sortable: false do |resource|
      if resource.cloudinary_public_id.present?
        image_tag resource.thumbnail_url, style: 'max-width: 60px; max-height: 60px; object-fit: cover;'
      else
        content_tag(:span, '—', class: 'text-gray-400')
      end
    end

    column :title
    column :category do |resource|
      status_tag resource.category
    end
    column :subcategory
    column :year
    column :author
    column :published do |resource|
      status_tag(resource.published ? 'Yes' : 'No', class: (resource.published ? 'yes' : 'no'))
    end
    actions
  end

  show do
    columns do
      column do
        panel "Video" do
          if resource.video_type.present? && resource.video_id.present?
            if resource.video_type == 'youtube'
              para do
                link_to "View on YouTube", "https://www.youtube.com/watch?v=#{resource.video_id}", target: '_blank'
              end
            elsif resource.video_type == 'vimeo'
              para do
                link_to "View on Vimeo", "https://vimeo.com/#{resource.video_id}", target: '_blank'
              end
            end
          end
        end

        panel "Image" do
          if resource.cloudinary_public_id.present?
            image_tag resource.image_url, style: 'max-width: 100%; display: block;'
          else
            para 'No image uploaded', class: 'text-gray-500'
          end
        end
      end

      column do
        panel "Details" do
          attributes_table_for resource do
            row :title
            row :slug
            row :category do
              status_tag resource.category
            end
            row :subcategory
            row :year
            row :author
            row :summary
            row :description
            row :content do
              simple_format(resource.content) if resource.content.present?
            end
            row :external_url do
              if resource.external_url.present?
                link_to resource.external_url, resource.external_url, target: '_blank'
              end
            end
            row :video_type
            row :video_id
            row :duration_seconds do
              if resource.duration_seconds.present?
                "#{resource.duration_seconds / 60} minutes #{resource.duration_seconds % 60} seconds"
              end
            end
            row :published do
              status_tag(resource.published ? 'Yes' : 'No', class: (resource.published ? 'yes' : 'no'))
            end
            row :is_indian_collection do
              resource.is_indian_collection? ? 'Yes' : 'No'
            end
            row :cloudinary_public_id
            row :original_filename
            row :created_at
            row :updated_at
          end
        end
      end
    end
  end
end