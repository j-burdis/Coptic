ActiveAdmin.register Exhibition do
  permit_params :title, :slug, :start_date, :end_date, :venue, :location, :description,
                :exhibition_type, :is_indian_collection, :published, :external_url,
                exhibition_images_attributes: [:id, :cloudinary_public_id, :original_filename, :caption, :position, :_destroy]

  # sidebar filters
  filter :title
  filter :exhibition_type, as: :select, collection: -> { Exhibition::EXHIBITION_TYPES }
  filter :start_date
  filter :end_date
  filter :published
  filter :created_at

  form html: { multipart: true } do |f|
    f.semantic_errors

    columns do
      column do
        f.inputs "Images" do
          # existing images
          if f.object.exhibition_images.any?
            f.object.exhibition_images.each_with_index do |img, index|
              f.inputs "Image #{index + 1}", for: [:exhibition_images, img] do |i|
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

          # upload image(s)
          li do
            label 'Upload New Images'
            text_node '<input name="exhibition[new_images][]" type="file" multiple="multiple" accept="image/*" style="margin: 10px 0;" />'.html_safe
            para "Select multiple images to upload. First image will be the primary/thumbnail.", class: 'inline-hints'
          end
        end
      end

      column do
        f.inputs "Basic Information" do
          f.input :title
          f.input :slug, hint: 'Leave blank to auto-generate from title'
          f.input :published
        end

        f.inputs "Dates" do
          f.input :start_date, as: :datepicker
          f.input :end_date, as: :datepicker
        end

        f.inputs "Location & Venue" do
          f.input :venue
          f.input :location
          f.input :external_url, hint: 'Link to external exhibition page or catalogue'
        end

        f.inputs "Exhibition Details" do
          f.input :exhibition_type,
                  as: :select,
                  collection: Exhibition::EXHIBITION_TYPES.map(&:first)

          f.input :description,
                  as: :text,
                  input_html: { rows: 6 }
        end

        f.inputs "Indian Collection" do
          f.input :is_indian_collection
        end
      end
    end

    f.actions
  end

  controller do
    def create
      @exhibition = Exhibition.new(permitted_params[:exhibition])

      if params[:exhibition][:new_images].present?
        params[:exhibition][:new_images].each_with_index do |uploaded_file, index|
          next if uploaded_file.blank?

          result = Cloudinary::Uploader.upload(uploaded_file.tempfile.path, folder: 'exhibitions')
          @exhibition.exhibition_images.build(
            cloudinary_public_id: result['public_id'],
            original_filename: uploaded_file.original_filename,
            position: index
          )
        end
      end

      if @exhibition.save
        redirect_to admin_exhibition_path(@exhibition), notice: 'Exhibition created successfully.'
      else
        render :new
      end
    end

    def update
      @exhibition = Exhibition.find(params[:id])

      if params[:exhibition][:new_images].present?
        current_max_position = @exhibition.exhibition_images.maximum(:position) || -1

        params[:exhibition][:new_images].each_with_index do |uploaded_file, index|
          next if uploaded_file.blank?

          result = Cloudinary::Uploader.upload(uploaded_file.tempfile.path, folder: 'exhibitions')
          @exhibition.exhibition_images.create(
            cloudinary_public_id: result['public_id'],
            original_filename: uploaded_file.original_filename,
            position: current_max_position + index + 1
          )
        end
      end

      if @exhibition.update(permitted_params[:exhibition])
        redirect_to admin_exhibition_path(@exhibition), notice: 'Exhibition updated successfully.'
      else
        render :edit
      end
    end

    def destroy
      @exhibition = Exhibition.find(params[:id])

      # delete all images from cloudinary
      @exhibition.exhibition_images.each do |img|
        begin
          Cloudinary::Uploader.destroy(img.cloudinary_public_id)
        rescue StandardError => e
          Rails.logger.error "Failed to delete image: #{e.message}"
        end
      end

      @exhibition.destroy
      redirect_to admin_exhibitions_path, notice: 'Exhibition was successfully deleted.'
    end
  end

  index do
    selectable_column
    id_column

    column :image, sortable: false do |exhibition|
      if exhibition.exhibition_images.any?
        image_tag exhibition.exhibition_images.first.thumbnail_url, style: 'max-width: 60px; max-height: 60px; object-fit: cover;'
      else
        content_tag(:span, '—', class: 'text-gray-400')
      end
    end

    column :title
    column :start_date
    column :end_date
    column :venue
    column :location
    column :exhibition_type
    actions
  end

  show do
    columns do
      column do
        panel "Images" do
          if exhibition.exhibition_images.any?
            exhibition.exhibition_images.each_with_index do |img, index|
              div style: 'margin-bottom: 20px;' do
                para "Image #{index + 1}", style: 'font-weight: bold; margin-bottom: 5px;'
                div style: 'min-height: 200px;' do
                  image_tag img.image_url, style: 'max-width: 100%; height: auto; display: block;'
                end
                if img.caption.present?
                  para img.caption, class: 'text-sm text-gray-600', style: 'margin-top: 5px;'
                end
              end
            end
          else
            para 'No images uploaded', class: 'text-gray-500'
          end
        end

        panel "Artworks in Exhibition" do
          if exhibition.artworks.any?
            table_for exhibition.artworks.order(year: :desc, title: :asc) do
              column :title do |artwork|
                link_to artwork.title, admin_artwork_path(artwork)
              end
              column :year
              column :medium
              column :category do |artwork|
                status_tag artwork.category
              end
            end
          else
            para "No artworks associated", class: 'text-gray-500'
          end
        end

        panel "Related Publications/Resources" do
          if exhibition.resources.any?
            table_for exhibition.resources.order(year: :desc) do
              column :title do |resource|
                link_to resource.title, admin_resource_path(resource)
              end
              column :category do |resource|
                status_tag resource.category
              end
              column :year
              column :author
            end
          else
            para "No publications/resources associated", class: 'text-gray-500'
          end
        end
      end

      column do
        panel "Details" do
          attributes_table_for exhibition do
            row :title
            row :slug
            row :start_date
            row :end_date
            row :venue
            row :location
            row :external_url do
              if exhibition.external_url.present?
                link_to exhibition.external_url, exhibition.external_url, target: '_blank'
              end
            end
            row :description
            row :exhibition_type do
              status_tag exhibition.exhibition_type
            end
            row :published do
              status_tag(exhibition.published ? 'Yes' : 'No', class: (exhibition.published ? 'yes' : 'no'))
            end
            row :is_indian_collection do
              exhibition.is_indian_collection? ? 'Yes' : 'No'
            end
            row :created_at
            row :updated_at
          end
        end
      end
    end
  end
end
