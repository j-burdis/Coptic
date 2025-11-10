class ArtworksController < ApplicationController
  def show
    @artwork = Artwork.published.find_by!(slug: params[:slug])

    # Handle artwork not found
    # unless @artwork
    #   redirect_to gallery_root_path, alert: "Artwork not found"
    #   return
    # end

    # Track which collection this artwork belongs to for breadcrumbs
    @category_path = case @artwork.category
                     when 'paintings' then gallery_paintings_path
                     when 'prints' then gallery_prints_path
                     when 'design' then gallery_design_path
                     when 'indian_leaves' then gallery_indian_leaves_path
                     when 'indian_waves' then gallery_indian_waves_path
                     when 'quantel_paintbox' then gallery_quantel_paintbox_path
                     when 'memories_of_bombay_mumbai' then gallery_memories_of_bombay_mumbai_path
                     when 'other' then gallery_other_path
                     else
                       gallery_root_path
                     end
  rescue ActiveRecord::RecordNotFound
    redirect_to gallery_root_path, alert: "Artwork not found"
  end
end
