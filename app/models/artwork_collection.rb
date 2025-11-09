class ArtworkCollection < ApplicationRecord
  belongs_to :artwork
  belongs_to :collection

  def self.ransackable_attributes(auth_object = nil)
    ["id", "artwork_id", "collection_id", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["artwork", "collection"]
  end
end
