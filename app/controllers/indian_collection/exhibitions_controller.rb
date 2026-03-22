module IndianCollection
  class ExhibitionsController < ApplicationController
    layout 'indian_collection'

    def list
      @exhibition_list = IndianCollectionExhibitionList.published.first
    end
  end
end
