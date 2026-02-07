class ChangeExhibitionYearsToDate < ActiveRecord::Migration[7.2]
  def change
    remove_column :exhibitions, :year, :integer
    remove_column :exhibitions, :year_end, :integer
    
    add_column :exhibitions, :start_date, :date
    add_column :exhibitions, :end_date, :date
  end
end
