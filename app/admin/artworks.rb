ActiveAdmin.register Artwork do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters

  permit_params :title, :slug, :year, :year_end, :date_display, :medium, :description, :dimensions,
                :category, :subcategory, :status, :published, :is_indian_collection,
                :indian_collection_category, :image, :cloudinary_public_id, :original_filename,
                :image_caption, :external_url, collection_ids: [], exhibition_ids: []

  index do
    selectable_column
    id_column

    column :image, sortable: false do |artwork|
      if artwork.cloudinary_public_id.present?
        image_tag artwork.thumbnail_url, style: 'max-width: 60px; max-height: 60px; object-fit: cover;'
      else
        content_tag(:span, '—', class: 'text-gray-400')
      end
    end

    column :title, sortable: :title do |artwork|
      link_to artwork.title, admin_artwork_path(artwork)
    end

    column :year, sortable: :year
    column :category, sortable: :category

    column :published, sortable: :published do |artwork|
      status_tag(artwork.published ? 'Yes' : 'No', class: (artwork.published ? 'yes' : 'no'))
    end

    column :collection do |artwork|
      if artwork.is_indian_collection?
        status_tag 'Indian Collection', class: 'info'
      else
        status_tag 'Main Collection', class: 'default'
      end
    end

    actions
  end

  # sidebar filters
  filter :title
  filter :category, as: :select, collection: -> { Artwork.categories }
  filter :status, as: :select, collection: -> { Artwork.statuses }
  filter :year
  filter :published
  filter :is_indian_collection, as: :select, label: 'Collection'
  filter :created_at

  show do
    columns do
      column do
        panel "Image" do
          if artwork.cloudinary_public_id.present?
            div style: 'min-height: 200px;' do
              image_tag artwork.image_url, style: 'max-width: 100%; height: auto; display: block;'
            end
          else
            para 'No image uploaded', class: 'text-gray-500'
          end

          if artwork.image_caption.present?
            para artwork.image_caption, class: 'text-sm text-gray-600 mt-2'
          end
        end

        panel "Collections" do
          if artwork.collections.any?
            table_for artwork.collections do
              column :name do |collection|
                link_to collection.name, admin_collection_path(collection)
              end
              column :location
              column :region
            end
          else
            para "No collections associated", class: 'text-gray-500'
          end
        end

        panel "Exhibitions" do
          if artwork.exhibitions.any?
            table_for artwork.exhibitions do
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

        panel "Related Artworks" do
          if artwork.related_to.any?
            table_for artwork.related_to do
              column :title do |related|
                link_to related.title, admin_artwork_path(related)
              end
              column :year
              column :category
            end
          else
            para "No related artworks", class: 'text-gray-500'
          end
        end
      end

      column do
        panel "Details" do
          attributes_table_for artwork do
            row :title
            row :slug
            row :year
            row :year_end
            row :medium
            row :description
            row :dimensions
            row :external_url do |artwork|
              link_to artwork.external_url, artwork.external_url, target: '_blank' if artwork.external_url.present?
            end
            row :category do
              status_tag artwork.category
            end
            row :subcategory
            row :status do
              status_tag artwork.status
            end
            row :published do
              status_tag(artwork.published ? 'Yes' : 'No', class: (artwork.published ? 'yes' : 'no'))
            end
            row :is_indian_collection do
              artwork.is_indian_collection? ? 'Yes' : 'No'
            end
            row :indian_collection_category
            row :cloudinary_public_id
            row :original_filename
            row :created_at
            row :updated_at
          end
        end
      end
    end
  end

  form do |f|
    f.semantic_errors

    columns do
      column do
        f.inputs "Image" do
          if f.object.cloudinary_public_id.present?
            li do
              label 'Current Image'
              div do
                image_tag f.object.large_url, style: 'max-width: 100%; display: block; margin: 10px 0;'
              end
            end
          end

          f.input :image,
                  as: :file,
                  hint: 'Upload a new image (JPG, PNG). This will replace the current image.',
                  input_html: { accept: 'image/*' }
          f.input :image_caption, as: :text, input_html: { rows: 2 }, hint: 'Optional caption for the image'
        end

        f.inputs "Relationships" do
          f.input :collections, 
                  as: :check_boxes,
                  collection: Collection.order(:name),
                  hint: 'Select collections that hold this artwork'

          f.input :exhibitions, 
                  as: :check_boxes,
                  collection: Exhibition.order(start_date: :desc, title: :asc),
                  hint: 'Select exhibitions featuring this artwork'
        end
      end

      column do
        f.inputs "Indian Collection" do
          f.input :is_indian_collection, 
                  label: 'Indian Collection Artwork',
                  hint: 'Check if this is part of the Indian Collection'

          f.input :indian_collection_category, 
                  as: :select,
                  collection: Artwork::INDIAN_COLLECTION_CATEGORIES,
                  include_blank: true
        end

        f.inputs "Basic Information" do
          f.input :title
          f.input :slug, hint: 'Leave blank to auto-generate from title'
          f.input :published
        end

        f.inputs "Date Information" do
          para "For <strong>Main Collection</strong>: Use Year fields (numeric).<br>For <strong>Indian Collection</strong>: Use Date Display (text) for flexible dates like 'c. 1650' or 'late 19th century'.".html_safe

          f.input :year, hint: 'Numeric year (e.g., 1950)'
          f.input :year_end, hint: 'Leave blank if same as year'
          f.input :date_display, hint: 'Text date for Indian Collection (e.g., "c. 1650", "late 19th century")'
        end

        f.inputs "Details" do
          f.input :medium
          f.input :dimensions, hint: 'e.g., 100 x 80 cm'
          f.input :description, as: :text, input_html: { rows: 6 }
          f.input :external_url, hint: 'Optional external link for this artwork'
        end

        f.inputs "Main Collection Categorization", 
                html: { style: f.object.is_indian_collection? ? 'opacity: 0.5; pointer-events: none;' : '' } do
          para "Not required for Indian Collection artworks" if f.object.is_indian_collection?

          f.input :category,
                  as: :select,
                  collection: Artwork.categories.keys,
                  include_blank: true,
                  required: !f.object.is_indian_collection?

          f.input :subcategory,
                  as: :select,
                  collection: Artwork::DESIGN_SUBCATEGORIES.map(&:first),
                  hint: 'Only required for Design category',
                  include_blank: true

          f.input :status,
                  as: :select,
                  collection: Artwork.statuses.keys,
                  include_blank: false
        end
      end
    end

    f.actions
  end

  controller do
    def create
      @artwork = Artwork.new(artwork_params)

      if params[:artwork][:image].present?
        upload = upload_to_cloudinary(params[:artwork][:image])
        @artwork.cloudinary_public_id = upload['public_id']
        @artwork.original_filename = params[:artwork][:image].original_filename
      end

      if @artwork.save
        redirect_to admin_artwork_path(@artwork), notice: 'Artwork was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @artwork = Artwork.find(params[:id])
      # if new image uploaded, delete old one and upload new
      if params[:artwork][:image].present?
        # delete old image
        if @artwork.cloudinary_public_id.present?
          begin
            Cloudinary::Uploader.destroy(@artwork.cloudinary_public_id)
          rescue StandardError => e
            Rails.logger.error "Failed to delete old image: #{e.message}"
          end
        end
        # upload new image
        upload = upload_to_cloudinary(params[:artwork][:image])
        @artwork.cloudinary_public_id = upload['public_id']
        @artwork.original_filename = params[:artwork][:image].original_filename
      end

      if @artwork.update(artwork_params)
        redirect_to admin_artwork_path(@artwork), notice: 'Artwork was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @artwork = Artwork.find(params[:id])

      if @artwork.cloudinary_public_id.present?
        begin
          Cloudinary::Uploader.destroy(@artwork.cloudinary_public_id)
        rescue StandardError => e
          Rails.logger.error "Failed to delete image: #{e.message}"
        end
      end

      @artwork.destroy
      redirect_to admin_artworks_path, notice: 'Artwork was successfully deleted.'
    end

    private

    def artwork_params
      params.require(:artwork).permit(
        :title, :slug, :year, :year_end, :date_display, :medium, :description, :dimensions,
        :category, :subcategory, :status, :published, :is_indian_collection, :indian_collection_category,
        :image, :image_caption, :external_url, collection_ids: [], exhibition_ids: []
      )
    end

    def upload_to_cloudinary(file)
      Cloudinary::Uploader.upload(
        file.tempfile,
        folder: 'artworks',
        use_filename: true,
        unique_filename: true,
        overwrite: false,
        resource_type: 'image'
      )
    end
  end
end
