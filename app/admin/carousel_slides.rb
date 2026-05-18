ActiveAdmin.register CarouselSlide do
  menu priority: 2

  permit_params :artwork_id, :image, :cloudinary_public_id, :original_filename,
                :quote_text, :quote_attribution_name, :quote_attribution_date,
                :position, :published

  index do
    selectable_column
    id_column

    column :image, sortable: false do |slide|
      if slide.cloudinary_public_id.present?
        image_tag slide.image_url, style: 'max-width: 80px; max-height: 60px; object-fit: cover;'
      else
        content_tag(:span, '—', class: 'text-gray-400')
      end
    end

    column :artwork do |slide|
      slide.artwork&.title
    end
    column :position
    column :published do |slide|
      status_tag(slide.published ? 'Yes' : 'No', class: (slide.published ? 'yes' : 'no'))
    end
    actions
  end

  filter :published
  filter :position

  form html: { multipart: true } do |f|
    f.semantic_errors

    columns do
      column do
        f.inputs "Image" do
          if f.object.cloudinary_public_id.present?
            li do
              label 'Current Image'
              div do
                image_tag f.object.image_url, style: 'max-width: 100%; display: block; margin: 10px 0;'
              end
            end
          end
          f.input :image, as: :file, hint: 'Full width background image for carousel slide',
                  input_html: { accept: 'image/*' }
        end

        f.inputs "Quote (optional)" do
          f.input :quote_text, as: :text, input_html: { rows: 4 },
                  hint: 'Optional quote to display over the image'
          f.input :quote_attribution_name, hint: 'e.g. "Howard Hodgkin"'
          f.input :quote_attribution_date, hint: 'e.g. "1995"'          
        end
      end

      column do
        f.inputs "Artwork" do
          f.input :artwork, as: :select,
                  collection: Artwork.published.order(:title).map { |a| [a.title, a.id] },
                  include_blank: false,
                  hint: 'The artwork this slide links to'
        end

        f.inputs "Settings" do
          f.input :position, hint: 'Display order (lower numbers appear first)'
          f.input :published
        end
      end
    end

    f.actions
  end

  show do
    columns do
      column do
        panel "Image" do
          if carousel_slide.cloudinary_public_id.present?
            image_tag carousel_slide.image_url, style: 'max-width: 100%; height: auto;'
          else
            para 'No image uploaded'
          end
        end
      end

      column do
        panel "Details" do
          attributes_table_for carousel_slide do
            row :artwork do
              link_to carousel_slide.artwork.title, admin_artwork_path(carousel_slide.artwork) if carousel_slide.artwork
            end
            row :quote_text
            row :quote_attribution_name
            row :quote_attribution_date
            row :position
            row :published
            row :created_at
            row :updated_at
          end
        end
      end
    end
  end

  controller do
    def create
      @carousel_slide = CarouselSlide.new(permitted_params[:carousel_slide])

      if params[:carousel_slide][:image].present?
        upload = Cloudinary::Uploader.upload(
          params[:carousel_slide][:image].tempfile,
          folder: 'carousel'
        )
        @carousel_slide.cloudinary_public_id = upload['public_id']
        @carousel_slide.original_filename = params[:carousel_slide][:image].original_filename
      end

      if @carousel_slide.save
        redirect_to admin_carousel_slide_path(@carousel_slide), notice: 'Carousel slide created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @carousel_slide = CarouselSlide.find(params[:id])

      if params[:carousel_slide][:image].present?
        if @carousel_slide.cloudinary_public_id.present?
          begin
            Cloudinary::Uploader.destroy(@carousel_slide.cloudinary_public_id)
          rescue StandardError => e
            Rails.logger.error "Failed to delete image: #{e.message}"
          end
        end

        upload = Cloudinary::Uploader.upload(
          params[:carousel_slide][:image].tempfile,
          folder: 'carousel'
        )
        @carousel_slide.cloudinary_public_id = upload['public_id']
        @carousel_slide.original_filename = params[:carousel_slide][:image].original_filename
      end

      if @carousel_slide.update(permitted_params[:carousel_slide])
        redirect_to admin_carousel_slide_path(@carousel_slide), notice: 'Carousel slide updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @carousel_slide = CarouselSlide.find(params[:id])
      if @carousel_slide.cloudinary_public_id.present?
        begin
          Cloudinary::Uploader.destroy(@carousel_slide.cloudinary_public_id)
        rescue StandardError => e
          Rails.logger.error "Failed to delete image: #{e.message}"
        end
      end
      @carousel_slide.destroy
      redirect_to admin_carousel_slides_path, notice: 'Carousel slide deleted.'
    end
  end
end
