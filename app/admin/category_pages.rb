ActiveAdmin.register CategoryPage do
  menu priority: 3, label: "Category Pages"

  permit_params :slug, :title, :description, :page_type, :position, :published, 
                :image, :cloudinary_public_id, :original_filename

  index do
    selectable_column
    id_column

    column :image, sortable: false do |category_page|
      if category_page.cloudinary_public_id.present?
        image_tag category_page.thumbnail_url, style: 'max-width: 80px; max-height: 60px; object-fit: cover;'
      else
        content_tag(:span, '—', class: 'text-gray-400')
      end
    end

    column :title, sortable: :title do |category_page|
      link_to category_page.title, admin_category_page_path(category_page)
    end

    column :slug, sortable: :slug

    column :page_type, sortable: :page_type do |category_page|
      status_tag category_page.page_type.titleize
    end

    column :artwork_count, sortable: false do |category_page|
      category_page.artwork_count
    end

    column :position, sortable: :position

    column :published, sortable: :published do |category_page|
      status_tag(category_page.published ? 'Yes' : 'No',
                 class: (category_page.published ? 'yes' : 'no'))
    end

    actions
  end

  filter :title
  filter :slug
  filter :page_type, as: :select, collection: -> { CategoryPage.page_types }
  filter :published
  filter :created_at

  show do
    columns do
      column do
        panel "Hero Image" do
          if category_page.cloudinary_public_id.present?
            image_tag category_page.hero_url, style: 'max-width: 100%; display: block;'
          else
            para 'No image uploaded', class: 'text-gray-500'
          end
        end

        panel "Statistics" do
          attributes_table_for category_page do
            row :artwork_count do
              category_page.artwork_count
            end
            row "View on site" do
              case category_page.page_type
              when 'gallery_category'
                link_to "View #{category_page.title}", 
                        send("gallery_#{category_page.slug.underscore}_path"),
                        target: '_blank'
              when 'design_subcategory'
                link_to "View #{category_page.title}",
                        gallery_design_subcategory_path(subcategory: category_page.slug),
                        target: '_blank'
              when 'special_collection'
                link_to "View #{category_page.title}",
                        send("gallery_#{category_page.slug.underscore}_path"),
                        target: '_blank'
              end
            rescue
              content_tag(:span, 'N/A', class: 'text-gray-400')
            end
          end
        end
      end

      column do
        panel "Details" do
          attributes_table_for category_page do
            row :title
            row :slug
            row :page_type do
              status_tag category_page.page_type.titleize
            end
            row :description do
              simple_format(category_page.description) if category_page.description.present?
            end
            row :position
            row :published do
              status_tag(category_page.published ? 'Yes' : 'No',
                        class: (category_page.published ? 'yes' : 'no'))
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

  form do |f|
    f.semantic_errors

    columns do
      column do
        f.inputs "Image" do
          if f.object.cloudinary_public_id.present?
            li do
              label 'Current Image'
              div do
                image_tag f.object.hero_url, 
                         style: 'max-width: 100%; display: block; margin: 10px 0;'
              end
            end
          end

          f.input :image, 
                  as: :file, 
                  hint: 'Upload a hero image (JPG, PNG). Recommended size: 1600x600px. This will replace the current image.',
                  input_html: { accept: 'image/*' }
        end
      end

      column do
        f.inputs "Basic Information" do
          f.input :title, 
                  hint: 'Display title for this category page'

          f.input :slug, 
                  hint: 'URL-friendly identifier (e.g., "paintings", "artplate"). Leave blank to auto-generate.'

          f.input :page_type,
                  as: :select,
                  collection: CategoryPage.page_types.keys.map { |k| [k.titleize, k] },
                  include_blank: false,
                  hint: 'Gallery Category = main categories, Design Subcategory = design projects, Special Collection = missing/destroyed/all'

          f.input :position,
                  hint: 'Lower numbers appear first. Use for custom ordering.'

          f.input :published
        end

        f.inputs "Content" do
          f.input :description,
                  as: :text,
                  input_html: { rows: 10 },
                  hint: 'Rich description shown on the category landing page. Supports line breaks.'
        end
      end
    end

    f.actions
  end

  controller do
    def create
      @category_page = CategoryPage.new(category_page_params)

      # generate slug if not provided
      if @category_page.slug.blank? && @category_page.title.present?
        @category_page.slug = @category_page.title.parameterize
      end

      # handle image upload
      if params[:category_page][:image].present?
        upload = upload_to_cloudinary(params[:category_page][:image])
        @category_page.cloudinary_public_id = upload['public_id']
        @category_page.original_filename = params[:category_page][:image].original_filename
      end

      if @category_page.save
        redirect_to admin_category_page_path(@category_page), 
                    notice: 'Category page was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @category_page = CategoryPage.find(params[:id])

      # handle image upload
      if params[:category_page][:image].present?
        # delete old image
        if @category_page.cloudinary_public_id.present?
          begin
            Cloudinary::Uploader.destroy(@category_page.cloudinary_public_id)
          rescue StandardError => e
            Rails.logger.error "Failed to delete old image: #{e.message}"
          end
        end

        # upload new image
        upload = upload_to_cloudinary(params[:category_page][:image])
        @category_page.cloudinary_public_id = upload['public_id']
        @category_page.original_filename = params[:category_page][:image].original_filename
      end

      if @category_page.update(category_page_params)
        redirect_to admin_category_page_path(@category_page), 
                    notice: 'Category page was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @category_page = CategoryPage.find(params[:id])

      # delete image from Cloudinary
      if @category_page.cloudinary_public_id.present?
        begin
          Cloudinary::Uploader.destroy(@category_page.cloudinary_public_id)
        rescue StandardError => e
          Rails.logger.error "Failed to delete image: #{e.message}"
        end
      end

      @category_page.destroy
      redirect_to admin_category_pages_path, 
                  notice: 'Category page was successfully deleted.'
    end

    private

    def category_page_params
      params.require(:category_page).permit(
        :title, :slug, :description, :page_type, :position, :published
      )
    end

    def upload_to_cloudinary(file)
      Cloudinary::Uploader.upload(
        file.tempfile,
        folder: 'category_pages',
        use_filename: true,
        unique_filename: true,
        overwrite: false,
        resource_type: 'image'
      )
    end
  end
end
