ActiveAdmin.register Exhibition do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment

  permit_params :title, :slug, :year, :year_end, :venue, :location,
  :description, :exhibition_type, :is_indian_collection, :published,
  :image, :cloudinary_public_id, :original_filename

  # or
  #
  # permit_params do
  #   permitted = [:title, :slug, :year, :year_end, :venue, :location, :description, :exhibition_type, :is_indian_collection, :published]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  # sidebar filters
  filter :title
  filter :exhibition_type, as: :select, exhibition: -> { Exhibition.exhibition_type }
  filter :year
  filter :year_end
  filter :published
  filter :created_at

  # form do |f|
  #   f.inputs 'Exhibition Details' do
  #     f.input :title
  #     f.input :slug
  #     f.input :year
  #     f.input :year_end
  #     f.input :venue
  #     f.input :location
  #     f.input :description
  #     f.input :exhibition_type, as: :select, collection: Exhibition.exhibition_types.keys
  #     f.input :is_indian_collection
  #     f.input :published
      
  #     # Add image upload
  #     f.input :image, as: :file, hint: f.object.cloudinary_public_id.present? ? image_tag(f.object.thumbnail_url) : content_tag(:span, "No image uploaded")
  #   end
  #   f.actions
  # end

  form do |f|
    f.semantic_errors

    columns do
      #
      # LEFT COLUMN
      #
      column do
        f.inputs "Image" do
          if f.object.cloudinary_public_id.present?
            li do
              label 'Current Image'
              div do
                image_tag(
                  f.object.image_url,
                  style: 'max-width: 100%; display: block; margin: 10px 0;'
                )
              end
            end
          end

          f.input :image,
                  as: :file,
                  hint: 'Upload a new image (JPG, PNG). This will replace the current image.',
                  input_html: { accept: 'image/*' }
        end
      end

      #
      # RIGHT COLUMN
      #
      column do
        f.inputs "Basic Information" do
          f.input :title
          f.input :slug, hint: 'Leave blank to auto-generate from title'
          f.input :published
        end

        f.inputs "Dates" do
          f.input :year
          f.input :year_end, hint: 'Leave blank if same as year'
        end

        f.inputs "Location & Venue" do
          f.input :venue
          f.input :location
        end

        f.inputs "Exhibition Details" do
          f.input :exhibition_type,
                  as: :select,
                  collection: Exhibition.exhibition_types.keys,
                  include_blank: false

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
      
      if params[:exhibition][:image].present?
        uploaded_file = params[:exhibition][:image]
        result = Cloudinary::Uploader.upload(uploaded_file.tempfile.path, folder: 'exhibitions')
        @exhibition.cloudinary_public_id = result['public_id']
        @exhibition.original_filename = uploaded_file.original_filename
      end
      
      if @exhibition.save
        redirect_to admin_exhibition_path(@exhibition), notice: 'Exhibition created successfully.'
      else
        render :new
      end
    end

    def update
      @exhibition = Exhibition.find(params[:id])
      
      if params[:exhibition][:image].present?
        uploaded_file = params[:exhibition][:image]
        result = Cloudinary::Uploader.upload(uploaded_file.tempfile.path, folder: 'exhibitions')
        @exhibition.cloudinary_public_id = result['public_id']
        @exhibition.original_filename = uploaded_file.original_filename
      end
      
      if @exhibition.update(permitted_params[:exhibition])
        redirect_to admin_exhibition_path(@exhibition), notice: 'Exhibition updated successfully.'
      else
        render :edit
      end
    end
  end
  
  index do
    selectable_column
    id_column

    column :image, sortable: false do |exhibition|
      if exhibition.cloudinary_public_id.present?
        image_tag exhibition.thumbnail_url, style: 'max-width: 60px; max-height: 60px; object-fit: cover;'
      else
        content_tag(:span, '—', class: 'text-gray-400')
      end
    end

    column :title
    column :year
    column :year_end
    column :venue
    column :location
    column :exhibition_type
    actions
  end

  show do
    columns do
      column do
        panel "Image" do
          if exhibition.cloudinary_public_id.present?
            image_tag exhibition.image_url, style: 'max-width: 100%; display: block;'
          else
            para 'No image uploaded', class: 'text-gray-500'
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
      end

      column do
        panel "Details" do
          attributes_table_for exhibition do
            row :title
            row :slug
            row :year
            row :year_end
            row :venue
            row :location
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
