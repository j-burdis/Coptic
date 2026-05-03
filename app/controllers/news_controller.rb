class NewsController < ApplicationController
  def index
    @news_items = NewsItem.published.page(params[:page]).per(12)
  end

  def show
    @news_item = NewsItem.published.find_by!(slug: params[:slug])
  end
end
