class Quote < ApplicationRecord
  validates :text, :author, :page_location, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["title", "page_location", "author", "published"]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  scope :published, -> { where(published: true) }
  scope :ordered, -> { order(position: :asc) }

  scope :gallery_landing, -> { where(page_location: 'gallery_landing') }
  scope :design_landing, -> { where(page_location: 'design_landing') }
  scope :resources_landing, -> { where(page_location: 'resources_landing') }

  def self.page_locations
    {
      'Gallery Landing' => 'gallery_landing',
      'Design Landing' => 'design_landing'
    }
  end
end
