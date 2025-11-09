class ArtworkExhibition < ApplicationRecord
  belongs_to :artwork
  belongs_to :exhibition

  def self.ransackable_attributes(auth_object = nil)
    ["id", "artwork_id", "exhibition_id", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["artwork", "exhibition"]
  end
end
