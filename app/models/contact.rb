class Contact < ApplicationRecord
  validates :name, presence: true

  CATEGORIES = ['paintings', 'prints', 'reproductions'].freeze

  scope :published, -> { where(published: true) }
  scope :ordered, -> { order(position: :asc, name: :asc) }

  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "category", "address", "phone", "fax", "email", 
     "website", "position", "published", "created_at", "updated_at"]
  end

    def self.ransackable_associations(auth_object = nil)
    []
  end
end