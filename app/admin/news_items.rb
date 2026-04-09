ActiveAdmin.register NewsItem do
  permit_params :title, :slug, :content, :excerpt, :published,
                :cloudinary_public_id, :original_filename, :image_caption,
                :external_url, :date, :image

  index do
    selectable_column
    id_column

    column :image, sortable: false do |news_item|
      if news_item.cloudinary_public_id.present?
        image_tag news_item.thumbnail_url, style: 'max-width: 60px; max-height: 60px; object-fit: cover;'
      else
        content_tag(:span, '—', class: 'text-gray-400')
      end
    end

    column :title
    column :published do |news_item|
      status_tag(news_item.published ? 'Yes' : 'No', class: (news_item.published ? 'yes' : 'no'))
    end
    column :date
    actions
  end

  filter :title
  filter :published
  filter :date
  filter :created_at

  show do
    columns do
      column do
        panel "Image" do
          if news_item.cloudinary_public_id.present?
            div style: 'min-height: 200px;' do
              image_tag news_item.large_url, style: 'max-width: 100%; height: auto; display: block;'
            end
            if news_item.image_caption.present?
              para news_item.image_caption, class: 'text-sm text-gray-600 mt-2'
            end
          else
            para 'No image uploaded', class: 'text-gray-500'
          end
        end
      end

      column do
        panel "Details" do
          attributes_table_for news_item do
            row :title
            row :slug
            row :date
            row :published do
              status_tag(news_item.published ? 'Yes' : 'No', class: (news_item.published ? 'yes' : 'no'))
            end
            row :external_url do
              if news_item.external_url.present?
                link_to news_item.external_url, news_item.external_url, target: '_blank'
              end
            end
            row :image_caption
            row :excerpt
            row :content
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
          f.input :image_caption,
                  as: :text,
                  input_html: { rows: 2 },
                  hint: 'Optional caption for the image'
        end
      end

      column do
        f.inputs "Basic Information" do
          f.input :title
          f.input :slug, hint: 'Leave blank to auto-generate from title'
          f.input :published
        end

        f.inputs "Date" do
          f.input :date, as: :datepicker, hint: 'Display date for this news item'
        end

        f.inputs "Content" do
          f.input :excerpt, as: :text, input_html: { rows: 3 },
                  hint: 'Brief summary shown in news listings'
          f.input :content, as: :text, input_html: { rows: 12 },
                  hint: 'Full content of the news item'
          f.input :external_url, hint: 'Optional external link — if present, links to this URL instead of the show page'
        end
      end
    end

    f.actions
  end

  controller do
    def create
      @news_item = NewsItem.new(permitted_params[:news_item])

      if params[:news_item][:image].present?
        upload = Cloudinary::Uploader.upload(
          params[:news_item][:image].tempfile,
          folder: 'news'
        )
        @news_item.cloudinary_public_id = upload['public_id']
        @news_item.original_filename = params[:news_item][:image].original_filename
      end

      if @news_item.save
        redirect_to admin_news_item_path(@news_item), notice: 'News item created successfully.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @news_item = NewsItem.find(params[:id])

      if params[:news_item][:image].present?
        if @news_item.cloudinary_public_id.present?
          begin
            Cloudinary::Uploader.destroy(@news_item.cloudinary_public_id)
          rescue StandardError => e
            Rails.logger.error "Failed to delete old image: #{e.message}"
          end
        end

        upload = Cloudinary::Uploader.upload(
          params[:news_item][:image].tempfile,
          folder: 'news'
        )
        @news_item.cloudinary_public_id = upload['public_id']
        @news_item.original_filename = params[:news_item][:image].original_filename
      end

      if @news_item.update(permitted_params[:news_item])
        redirect_to admin_news_item_path(@news_item), notice: 'News item updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @news_item = NewsItem.find(params[:id])

      if @news_item.cloudinary_public_id.present?
        begin
          Cloudinary::Uploader.destroy(@news_item.cloudinary_public_id)
        rescue StandardError => e
          Rails.logger.error "Failed to delete image: #{e.message}"
        end
      end

      @news_item.destroy
      redirect_to admin_news_items_path, notice: 'News item deleted successfully.'
    end
  end
end
