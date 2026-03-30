module IndianCollection
  class ExhibitionsController < ApplicationController
    layout 'indian_collection'

    def list
      raw_list = IndianCollectionExhibitionList.published.first
      
      if raw_list&.content.present?
        @decades = parse_exhibition_list(raw_list.content)
      end
    end

    private

    def parse_exhibition_list(content)
      decades = {}
      current_decade = nil

      content.each_line do |line|
        line = line.strip
        next if line.blank?

        if line.match?(/^\d{4}s$/)
          current_decade = line
          decades[current_decade] = []
        elsif current_decade
          decades[current_decade] << line
        end
      end

      decades
    end
  end
end