module GalleryHelper
  def category_path_for(category_name)
    case category_name.downcase
    when 'paintings' then gallery_paintings_path
    when 'prints' then gallery_prints_path
    when 'indian leaves' then gallery_indian_leaves_path
    when 'indian waves' then gallery_indian_waves_path
    when 'design' then gallery_design_path
    when 'quantel paintbox' then gallery_quantel_paintbox_path
    when 'memories of bombay / mumbai' then gallery_memories_of_bombay_mumbai_path
    when 'other' then gallery_other_path
    else gallery_all_path
    end
  end
end