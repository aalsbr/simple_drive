class Blob < ApplicationRecord
  # Validations
  validates :blob_id, presence: true, uniqueness: true
  validates :size, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :storage_provider, presence: true
  
  # Virtual attribute for content (not stored in this model)
  attr_accessor :content
  
  # Find by custom blob_id instead of primary key id
  def self.find_by_blob_id(blob_id)
    find_by(blob_id: blob_id)
  end
end
