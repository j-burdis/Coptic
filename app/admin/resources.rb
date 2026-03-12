ActiveAdmin.register Resource do
  permit_params :title, :slug, :category, :subcategory, :year, :year_end, :date, :show_day, 
                :author, :publisher, :isbn, :summary, :description, :external_url, 
                :video_type, :video_id, :is_indian_collection, :published, 
                :image, :cloudinary_public_id, :original_filename, :image_caption, 
                exhibition_ids: [],
                resource_images_attributes: [:id, :cloudinary_public_id, :original_filename, :caption, :position, :_destroy]

  # Sidebar filters
  filter :title
  filter :category, as: :select, collection: -> { Resource.categories.keys }
  filter :subcategory
  filter :year
  filter :author
  filter :published
  filter :created_at

  index do
    selectable_column
    id_column

    column :image, sortable: false do |resource|
      if resource.resource_images.any?
        image_tag resource.resource_images.first.thumbnail_url, style: 'max-width: 60px; max-height: 60px; object-fit: cover;'
      elsif resource.cloudinary_public_id.present?
        image_tag resource.thumbnail_url, style: 'max-width: 60px; max-height: 60px; object-fit: cover;'
      else
        content_tag(:span, '—', class: 'text-gray-400')
      end
    end

    column :title
    column :category do |resource|
      status_tag resource.category
    end
    column :year do |resource|
      resource.year_display
    end
    column :subcategory
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
          else
            para 'No video', class: 'text-gray-500'
          end
        end

        panel "Images" do
          if resource.resource_images.any?
            resource.resource_images.each_with_index do |img, index|
              div style: 'margin-bottom: 20px;' do
                para "Image #{index + 1}", style: 'font-weight: bold; margin-bottom: 5px;'
                div style: 'min-height: 200px;' do
                  image_tag img.image_url, style: 'max-width: 100%; height: auto; display: block;'
                end
                if img.caption.present?
                  para img.caption, class: 'text-sm text-gray-500', style: 'margin-top: 5px;'
                end
              end
            end
          elsif resource.cloudinary_public_id.present?
            para "Image", style: 'font-weight: bold; margin-bottom: 5px;'
            div style: 'min-height: 200px;' do
              image_tag resource.image_url, style: 'max-width: 100%; height: auto; display: block;'
            end
            if resource.image_caption.present?
              para resource.image_caption, class: 'text-sm text-gray-500', style: 'margin-top: 5px;'
            end
          else
            para 'No images uploaded', class: 'text-gray-500'
          end
        end

        panel "Related Exhibitions" do
          if resource.exhibitions.any?
            table_for resource.exhibitions.order(start_date: :desc) do
              column :title do |exhibition|
                link_to exhibition.title, admin_exhibition_path(exhibition)
              end
              column :dates do |exhibition|
                exhibition.year_display
              end
              column :venue
              column :location
            end
          else
            para "No exhibitions associated", class: 'text-gray-500'
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
            row :year_end
            row :date
            row :show_day do
              resource.show_day? ? 'Yes' : 'No'
            end
            row :author
            row :publisher
            row :isbn
            row :summary
            row :description
            row :external_url do
              if resource.external_url.present?
                link_to resource.external_url, resource.external_url, target: '_blank'
              end
            end
            row :published do
              status_tag(resource.published ? 'Yes' : 'No', class: (resource.published ? 'yes' : 'no'))
            end
            row :is_indian_collection do
              resource.is_indian_collection? ? 'Yes' : 'No'
            end
            row :created_at
            row :updated_at
          end
        end
      end
    end
  end

  form html: { multipart: true } do |f|
    f.semantic_errors

    columns do
      column do
        f.inputs "Video (Films & Audio only)" do
          f.input :video_type, as: :select, collection: ['youtube', 'vimeo'], include_blank: 'No video',
                               hint: 'Leave blank if not a video resource'
          f.input :video_id,
                  hint: "For YouTube: the ID from youtube.com/watch?v=VIDEO_ID<br>For Vimeo: the ID from vimeo.com/VIDEO_ID".html_safe
        end

        f.inputs "Images" do
          # show existing images
          if f.object.resource_images.any?
            f.object.resource_images.each_with_index do |img, index|
              f.inputs "Image #{index + 1}", for: [:resource_images, img] do |i|
                i.input :cloudinary_public_id, as: :hidden
                i.input :original_filename, as: :hidden
                i.input :position, as: :hidden, input_html: { value: index }
                
                li do
                  image_tag img.image_url, style: 'max-width: 100%; height: auto; margin: 10px 0;'
                end
                
                i.input :caption, as: :text, input_html: { rows: 2 }
                i.input :_destroy, as: :boolean, label: 'Delete this image'
              end
            end
          end

          # show single image if exists and no new images
          if f.object.cloudinary_public_id.present? && f.object.resource_images.empty?
            li do
              label 'Current Image'
              div do
                image_tag(
                  f.object.image_url,
                  style: 'max-width: 100%; display: block; margin: 10px 0;'
                )
              end
              para "Upload new images below to use the multi-image system.", class: 'inline-hints'
            end

            f.input :cloudinary_public_id, 
              as: :boolean,
              label: 'Delete legacy image',
              hint: 'Check this box to remove the old single image',
              input_html: { 
                value: '',
                checked: false,
                onclick: "if(this.checked) { this.value = ''; this.form.querySelector('input[name=\"resource[cloudinary_public_id]\"][type=\"hidden\"]')?.remove(); } else { this.value = '#{f.object.cloudinary_public_id}'; }"
              }
          end

          # upload new images
          li do
            label 'Upload New Images'
            text_node '<input name="resource[new_images][]" type="file" multiple="multiple" accept="image/*" style="margin: 10px 0;" />'.html_safe
            para "Select multiple images", class: 'inline-hints'
          end
        end

        f.inputs "Relationships" do
          f.input :exhibitions,
                  as: :check_boxes,
                  collection: Exhibition.published.order(start_date: :desc),
                  hint: 'Select exhibitions featuring this resource'
        end
      end

      column do
        f.inputs "Basic Information" do
          f.input :title, hint: 'Leave blank for chronology entries (auto-generated from year)'
          f.input :slug, hint: 'Leave blank to auto-generate from title (not used for chronology)'
          f.input :category, as: :select, collection: Resource.categories.keys, include_blank: false
          f.input :subcategory, as: :select,
                                collection: (Resource::TEXT_SUBCATEGORIES + Resource::PUBLICATION_SUBCATEGORIES).map(&:first), 
                                include_blank: true,
                                hint: 'Required for Texts and Publications'
          f.input :published
        end

        f.inputs "Date Information" do
          f.input :year, hint: 'Primary year or use date field below for specific dates'
          f.input :year_end, hint: 'Optional: for chronology year ranges (e.g., 1940–1945)'
          f.input :date, as: :datepicker,
                         hint: 'Optional: for specific dates (overrides year field)'
          f.input :show_day, as: :boolean,
                             hint: 'Check to show day in date display (28th March 2024 vs March 2024)'
        end

        f.inputs "Content Details" do
          f.input :author, hint: 'Author/creator of the resource'
          f.input :publisher, hint: 'For publications and texts'
          f.input :isbn, hint: 'For publications only'
          f.input :summary, as: :text, input_html: { rows: 3 },
                            hint: 'Brief summary (shown in previews)'
          f.input :description, as: :text, input_html: { rows: 6 },
                                hint: 'Full description (used if summary not provided)'
          f.input :external_url, hint: 'Link to purchase publication or view full text'
        end

        f.inputs "Indian Collection" do
          f.input :is_indian_collection,
                  hint: 'Check if this resource is part of the Indian Collection'
        end
      end
    end

    f.actions
  end

  controller do
    def create
      @resource = Resource.new(permitted_params[:resource])

      # handle new images
      if params[:resource][:new_images].present?
        params[:resource][:new_images].each_with_index do |uploaded_file, index|
          next if uploaded_file.blank?
          
          result = Cloudinary::Uploader.upload(uploaded_file.tempfile.path, folder: 'resources')
          @resource.resource_images.build(
            cloudinary_public_id: result['public_id'],
            original_filename: uploaded_file.original_filename,
            position: index
          )
        end
      end

      if @resource.save
        redirect_to admin_resource_path(@resource), notice: 'Resource created successfully.'
      else
        render :new
      end
    end

    def update
      @resource = Resource.find(params[:id])

      # handle new images
      if params[:resource][:new_images].present?
        current_max_position = @resource.resource_images.maximum(:position) || -1
        
        params[:resource][:new_images].each_with_index do |uploaded_file, index|
          next if uploaded_file.blank?
          
          result = Cloudinary::Uploader.upload(uploaded_file.tempfile.path, folder: 'resources')
          @resource.resource_images.create(
            cloudinary_public_id: result['public_id'],
            original_filename: uploaded_file.original_filename,
            position: current_max_position + index + 1
          )
        end
      end

      if @resource.update(permitted_params[:resource])
        redirect_to admin_resource_path(@resource), notice: 'Resource updated successfully.'
      else
        render :edit
      end
    end

    def destroy
      @resource = Resource.find(params[:id])

      # delete all images from Cloudinary
      @resource.resource_images.each do |img|
        begin
          Cloudinary::Uploader.destroy(img.cloudinary_public_id)
        rescue StandardError => e
          Rails.logger.error "Failed to delete image: #{e.message}"
        end
      end

      # delete single image if exists
      if @resource.cloudinary_public_id.present?
        begin
          Cloudinary::Uploader.destroy(@resource.cloudinary_public_id)
        rescue StandardError => e
          Rails.logger.error "Failed to delete image: #{e.message}"
        end
      end

      @resource.destroy
      redirect_to admin_resources_path, notice: 'Resource was successfully deleted.'
    end
  end
end
