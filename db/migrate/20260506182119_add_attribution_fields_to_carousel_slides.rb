class AddAttributionFieldsToCarouselSlides < ActiveRecord::Migration[7.2]
  def change
    add_column :carousel_slides, :quote_attribution_name, :string
    add_column :carousel_slides, :quote_attribution_date, :string
  end
end
