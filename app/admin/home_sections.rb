ActiveAdmin.register HomeSection do
  permit_params :title, :description, :image, :image_cloudinary_public_id,
                :image_original_filename, :image_caption, :link_url, :link_text,
                :video_url, :layout, :position, :published

  index do
    selectable_column
    id_column

    column :image, sortable: false do |section|
      if section.image_cloudinary_public_id.present?
        image_tag section.thumbnail_url, style: 'max-width: 60px; max-height: 60px; object-fit: cover;'
      else
        content_tag(:span, '—', class: 'text-gray-400')
      end
    end

    column :title
    column :layout
    column :position
    column :published do |section|
      status_tag(section.published ? 'Yes' : 'No', class: (section.published ? 'yes' : 'no'))
    end
    actions
  end

  show do
    columns do
      column do
        panel "Image" do
          if home_section.image_cloudinary_public_id.present?
            div do
              image_tag home_section.image_url, style: 'max-width: 100%; height: auto; display: block;'
            end
            if home_section.image_caption.present?
              para home_section.image_caption, class: 'text-sm text-gray-500', style: 'margin-top: 5px;'
            end
          else
            para 'No image uploaded', class: 'text-gray-500'
          end
        end
      end

      column do
        panel "Details" do
          attributes_table_for home_section do
            row :title
            row :description
            row :link_url do
              if home_section.link_url.present?
                link_to home_section.link_url, home_section.link_url, target: '_blank'
              end
            end
            row :link_text
            row :video_url do
              if home_section.video_url.present?
                link_to home_section.video_url, home_section.video_url, target: '_blank'
              end
            end
            row :layout
            row :position
            row :published do
              status_tag(home_section.published ? 'Yes' : 'No', class: (home_section.published ? 'yes' : 'no'))
            end
            row :created_at
            row :updated_at
          end
        end
      end
    end
  end

  filter :title
  filter :published

  form html: { multipart: true } do |f|
    f.semantic_errors

    columns do
      column do
        f.inputs "Image" do
          if f.object.image_cloudinary_public_id.present?
            li do
              label 'Current Image'
              div do
                image_tag f.object.image_url, style: 'max-width: 100%; display: block; margin: 10px 0;'
              end
            end
          end
          f.input :image, as: :file, input_html: { accept: 'image/*' }
          f.input :image_caption, hint: 'Optional caption shown below the image'
        end
      end

      column do
        f.inputs "Content" do
          f.input :title
          f.input :description, as: :text, input_html: { rows: 8 },
                  hint: 'HTML supported. Use &lt;a&gt; tags for links within text.'
          f.input :link_url, hint: 'Primary link URL for this section'
          f.input :link_text, hint: 'Link text e.g. "Explore Artworks ››"'
          f.input :video_url, hint: 'Vimeo or YouTube URL for video modal (optional)'
        end

        f.inputs "Settings" do
          f.input :layout, as: :select,
                  collection: HomeSection::LAYOUTS.map { |l| [l.titleize.gsub('_', ' '), l] },
                  include_blank: false
          f.input :position
          f.input :published
        end
      end
    end

    f.actions
  end

  controller do
    def create
      @home_section = HomeSection.new(permitted_params[:home_section])

      if params[:home_section][:image].present?
        upload = Cloudinary::Uploader.upload(
          params[:home_section][:image].tempfile,
          folder: 'home_sections'
        )
        @home_section.image_cloudinary_public_id = upload['public_id']
        @home_section.image_original_filename = params[:home_section][:image].original_filename
      end

      if @home_section.save
        redirect_to admin_home_section_path(@home_section), notice: 'Section created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @home_section = HomeSection.find(params[:id])

      if params[:home_section][:image].present?
        if @home_section.image_cloudinary_public_id.present?
          begin
            Cloudinary::Uploader.destroy(@home_section.image_cloudinary_public_id)
          rescue StandardError => e
            Rails.logger.error "Failed to delete image: #{e.message}"
          end
        end

        upload = Cloudinary::Uploader.upload(
          params[:home_section][:image].tempfile,
          folder: 'home_sections'
        )
        @home_section.image_cloudinary_public_id = upload['public_id']
        @home_section.image_original_filename = params[:home_section][:image].original_filename
      end

      if @home_section.update(permitted_params[:home_section])
        redirect_to admin_home_section_path(@home_section), notice: 'Section updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @home_section = HomeSection.find(params[:id])
      if @home_section.image_cloudinary_public_id.present?
        begin
          Cloudinary::Uploader.destroy(@home_section.image_cloudinary_public_id)
        rescue StandardError => e
          Rails.logger.error "Failed to delete image: #{e.message}"
        end
      end
      @home_section.destroy
      redirect_to admin_home_sections_path, notice: 'Section deleted.'
    end
  end
end
