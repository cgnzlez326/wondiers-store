class Tenant < ApplicationRecord
  validates :name, :domain, :schema_name, presence: true
  validates :domain, :schema_name, uniqueness: true

  scope :active, -> { where(status: "active") }
end
