module ApplicationHelper
  def page_title
    if content_for?(:title)
      "#{content_for(:title)} - Howard Hodgkin".html_safe
    else
      "Howard Hodgkin"
    end
  end

  def flash_class(type)
    case type.to_sym
    when :notice, :success
      "bg-green-100 text-green-800 border border-green-300"
    when :alert, :error
      "bg-red-100 text-red-800 border border-red-300"
    when :warning
      "bg-yellow-100 text-yellow-800 border border-yellow-300"
    else
      "bg-blue-100 text-blue-800 border border-blue-300"
    end
  end

  def flash_icon(type)
    case type.to_sym
    when :notice, :success
      "fa-solid fa-circle-check text-green-600"
    when :alert, :error
      "fa-solid fa-circle-exclamation text-red-600"
    when :warning
      "fa-solid fa-triangle-exclamation text-yellow-600"
    else
      "fa-solid fa-circle-info text-blue-600"
    end
  end

  def resource_preview(resource, words: 50)
    if resource.summary.present?
      resource.summary
    elsif resource.description.present?
      truncate_words(resource.description, words, omission: ' [...]')
    else
      ''
    end
  end

  def search_excerpt(text, query, before: 10, after: 20)
    return '' if text.blank? || query.blank?

    clean_text = strip_tags(text).gsub(/\s+/, ' ').strip
    words = clean_text.split(' ')

    match_index = words.index { |word| word.downcase.include?(query.downcase) }
    return truncate_words(clean_text, after, omission: ' [...]') if match_index.nil?

    start_index = [match_index - before, 0].max
    end_index = [match_index + after, words.length - 1].min

    excerpt_words = words[start_index..end_index].map do |word|
      if word.downcase.include?(query.downcase)
        ERB::Util.html_escape(word).gsub(
          /#{Regexp.escape(query)}/i,
          "<span style=\"color: #EC5840;\">\\0</span>"
        ).html_safe
      else
        ERB::Util.html_escape(word)
      end
    end

    excerpt = excerpt_words.join(' ')
    excerpt = '... ' + excerpt if start_index > 0
    excerpt = excerpt + ' ...' if end_index < words.length - 1
    
    excerpt.html_safe
  end

  def highlight_query(text, query)
    return '' if text.blank? || query.blank?
    
    clean_text = strip_tags(text)
    ERB::Util.html_escape(clean_text).gsub(
      /#{Regexp.escape(query)}/i,
      "<span style=\"color: #EC5840;\">\\0</span>"
    ).html_safe
  end

  def indian_collection_category_path_for(category)
    case category
    when 'portrait' then indian_collection_gallery_portrait_path
    when 'elephants' then indian_collection_gallery_elephants_path
    when 'flora_fauna' then indian_collection_gallery_flora_fauna_path
    else
      indian_collection_gallery_root_path
    end
  end

  private

  def truncate_words(text, word_count, options = {})
    omission = options[:omission] || '...'
    words = text.split
    return text if words.length <= word_count

    words[0...word_count].join(' ') + omission
  end
end
