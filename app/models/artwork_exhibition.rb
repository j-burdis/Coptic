class ArtworkExhibition < ApplicationRecord
  belongs_to :artwork
  belongs_to :exhibition
end
