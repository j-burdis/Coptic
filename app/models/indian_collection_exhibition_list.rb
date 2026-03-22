class IndianCollectionExhibitionList < ApplicationRecord
  validates :content, presence: true

  scope :published, -> { where(published: true) }

  def self.ransackable_attributes(auth_object = nil)
    ["id", "content", "published", "created_at", "updated_at"]
  end
end
