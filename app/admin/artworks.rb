ActiveAdmin.register Artwork do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :title, :slug, :year, :year_end, :medium, :description, :dimensions,
                :category, :subcategory, :status, :published, :is_indian_collection,
                :indian_collection_category, :image, :cloudinary_public_id, :original_filename
  #
  # or
  #
  # permit_params do
  #   permitted = [:title, :slug, :year, :year_end, :medium, :description, :dimensions, :category, :subcategory, :status, :published, :is_indian_collection, :indian_collection_category, :cloudinary_public_id, :original_filename]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  form do |f|
    f.inputs "Artwork Details" do
      f.input :title
      f.input :slug
      f.input :year
      f.input :year_end
      f.input :medium
      f.input :description
      f.input :dimensions
      f.input :category
      f.input :subcategory
      f.input :status
      f.input :published
      f.input :is_indian_collection
      f.input :indian_collection_category
      # f.input :year
      # f.input :year
      # ... your normal fields ...
    end

    f.inputs "Image Upload" do
      if f.object.cloudinary_public_id.present?
        li do
          label 'Current Image'
          div do
            image_tag f.object.thumbnail_url, style: 'max-width: 300px;'
          end
        end
      end

      f.input :image,
              as: :file,
              hint: 'Upload a new image (JPG, PNG)',
              input_html: { accept: 'image/*' }
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

    private

    def artwork_params
      params.require(:artwork).permit(
        :title, :slug, :year, :year_end, :medium, :description, :dimensions,
        :category, :subcategory, :status, :published, :is_indian_collection,
        :indian_collection_category
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
