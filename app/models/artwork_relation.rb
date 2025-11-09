class ArtworkRelation < ApplicationRecord
  belongs_to :artwork
  belongs_to :related_artwork, class_name: 'Artwork'

  validates :artwork_id, uniqueness: { scope: :related_artwork_id }
  validates :artwork_id, comparison: {
    other_than: :related_artwork_id,
    message: "cannot be related to itself"
  }

  def self.ransackable_attributes(auth_object = nil)
    ["id", "artwork_id", "related_artwork_id", "position",
     "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["artwork", "related_artwork"]
  end
end
