class ResourceExhibition < ApplicationRecord
  belongs_to :resource
  belongs_to :exhibition

  validates :resource_id, uniqueness: { scope: :exhibition_id }
end