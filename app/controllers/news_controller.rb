class NewsController < ApplicationController
  def index
    @news_items = NewsItem.published.page(params[:page]).per(10)
  end

  def show
    @news_item = NewsItem.published.find_by!(slug: params[:slug])
  rescue ActiveRecord::RecordNotFound
    redirect_to news_index_path, alert: "News item not found"
  end
end
