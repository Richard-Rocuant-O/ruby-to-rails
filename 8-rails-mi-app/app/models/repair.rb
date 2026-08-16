class Repair < ApplicationRecord
  belongs_to :car
  has_many :reports, as: :reportable, dependent: :destroy

  validates :description, presence: true
  validates :status, inclusion: { in: %w[pending in_progress completed] }
  validates :cost, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :expensive, -> { where("cost > ?", 100) }
end
