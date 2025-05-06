class CreateBlobs < ActiveRecord::Migration[7.1]
  def change
    create_table :blobs do |t|
      t.string :blob_id
      t.integer :size
      t.string :backend
      t.string :checksum

      t.timestamps
    end
    add_index :blobs, :blob_id, unique: true
  end
end
