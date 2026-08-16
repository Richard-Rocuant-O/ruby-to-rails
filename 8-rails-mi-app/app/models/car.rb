class Car < ApplicationRecord
  has_many :repairs, dependent: :destroy

  scope :recent_models, -> { where("year >= ?", 5.years.ago.year) }
end
