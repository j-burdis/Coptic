ActiveAdmin.register Collection do
  permit_params :name, :slug, :location, :region, :description, :website, :published,
                :image, :cloudinary_public_id, :original_filename

  filter :name
  filter :location
  filter :region

  form html: { multipart: true } do |f|
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
                  hint: 'Upload an image (JPG, PNG). This will replace the current image.',
                  input_html: { accept: 'image/*' }
        end


      end

      column do
          f.inputs "Collection details" do
          f.input :name
          f.input :slug
          f.input :location
          f.input :region
          f.input :website
          f.input :published
        end

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

    column :image, sortable: false do |collection|
      if collection.cloudinary_public_id.present?
        image_tag collection.thumbnail_url, style: 'max-width: 60px; max-height: 60px; object-fit: cover;'
      else
        content_tag(:span, '—', class: 'text-gray-400')
      end
    end
  
    column :name
    column :location
    column :region
    column :website
    actions
  end

  show do
    columns do
      column do
        panel "Image" do
          if collection.cloudinary_public_id.present?
            image_tag collection.large_url, style: 'max-width: 100%; height: auto; display: block;'
          else
            para 'No image uploaded', class: 'text-gray-500'
          end
        end
      end

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

    controller do
    def create
      @collection = Collection.new(permitted_params[:collection])

      if params[:collection][:image].present?
        upload = Cloudinary::Uploader.upload(
          params[:collection][:image].tempfile,
          folder: 'collections'
        )
        @collection.cloudinary_public_id = upload['public_id']
        @collection.original_filename = params[:collection][:image].original_filename
      end

      if @collection.save
        redirect_to admin_collection_path(@collection), notice: 'Collection created successfully.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @collection = Collection.find(params[:id])

      if params[:collection][:image].present?
        if @collection.cloudinary_public_id.present?
          begin
            Cloudinary::Uploader.destroy(@collection.cloudinary_public_id)
          rescue StandardError => e
            Rails.logger.error "Failed to delete old image: #{e.message}"
          end
        end

        upload = Cloudinary::Uploader.upload(
          params[:collection][:image].tempfile,
          folder: 'collections'
        )
        @collection.cloudinary_public_id = upload['public_id']
        @collection.original_filename = params[:collection][:image].original_filename
      end

      if @collection.update(permitted_params[:collection])
        redirect_to admin_collection_path(@collection), notice: 'Collection updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @collection = Collection.find(params[:id])

      if @collection.cloudinary_public_id.present?
        begin
          Cloudinary::Uploader.destroy(@collection.cloudinary_public_id)
        rescue StandardError => e
          Rails.logger.error "Failed to delete image: #{e.message}"
        end
      end

      @collection.destroy
      redirect_to admin_collections_path, notice: 'Collection deleted successfully.'
    end
  end
end
