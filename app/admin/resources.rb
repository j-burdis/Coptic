ActiveAdmin.register Resource do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :title, :slug, :category, :subcategory, :year, :author, :summary, :description, :content, :external_url, :cloudinary_public_id, :original_filename, :video_type, :video_id, :embed_code, :duration_seconds, :is_indian_collection, :published
  #
  # or
  #
  # permit_params do
  #   permitted = [:title, :slug, :category, :subcategory, :year, :author, :summary, :description, :content, :external_url, :cloudinary_public_id, :original_filename, :video_type, :video_id, :embed_code, :duration_seconds, :is_indian_collection, :published]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  permit_params :title, :slug, :category, :subcategory, :year, :author,
                :summary, :description, :content, :external_url,
                :cloudinary_public_id, :original_filename, :image,
                :video_type, :video_id, :embed_code, :duration_seconds,
                :is_indian_collection, :published

  form do |f|
    f.inputs 'Resource Details' do
      f.input :title
      f.input :slug
      f.input :category, as: :select, collection: Resource.categories.keys
      f.input :subcategory
      f.input :year
      f.input :author
      f.input :summary
      f.input :description
      f.input :content
      f.input :external_url

      f.input :image, as: :file, hint: f.object.cloudinary_public_id.present? ? image_tag(f.object.thumbnail_url) : content_tag(:span, "No image uploaded")

      f.input :video_type, as: :select, collection: ['youtube', 'vimeo'], include_blank: 'No video'
      f.input :video_id, hint: "For YouTube: the ID from youtube.com/watch?v=VIDEO_ID, For Vimeo: the ID from vimeo.com/VIDEO_ID"
      f.input :duration_seconds, hint: "Video duration in seconds (optional)"

      f.input :is_indian_collection
      f.input :published
    end
    f.actions
  end

  controller do
    def create
      @resource = Resource.new(permitted_params[:resource])
      
      if params[:resource][:image].present?
        uploaded_file = params[:resource][:image]
        result = Cloudinary::Uploader.upload(uploaded_file.tempfile.path, folder: 'resources')
        @resource.cloudinary_public_id = result['public_id']
        @resource.original_filename = uploaded_file.original_filename
      end
      
      if @resource.save
        redirect_to admin_resource_path(@resource), notice: 'Resource created successfully.'
      else
        render :new
      end
    end

    def update
      @resource = Resource.find(params[:id])
      
      if params[:resource][:image].present?
        uploaded_file = params[:resource][:image]
        result = Cloudinary::Uploader.upload(uploaded_file.tempfile.path, folder: 'resources')
        @resource.cloudinary_public_id = result['public_id']
        @resource.original_filename = uploaded_file.original_filename
      end
      
      if @resource.update(permitted_params[:resource])
        redirect_to admin_resource_path(@resource), notice: 'Resource updated successfully.'
      else
        render :edit
      end
    end
  end
end
