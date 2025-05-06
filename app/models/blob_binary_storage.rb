class BlobBinaryStorage < ApplicationRecord
  # Validations
  validates :blob_id, presence: true, uniqueness: true
  validates :content, presence: true
  
  # Find by custom blob_id instead of primary key id
  def self.find_by_blob_id(blob_id)
    find_by(blob_id: blob_id)
  end
end
