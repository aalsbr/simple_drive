class CreateBlobContents < ActiveRecord::Migration[7.1]
  def change
    create_table :blob_contents do |t|
      t.string :blob_id
      t.text :content

      t.timestamps
    end
    add_index :blob_contents, :blob_id, unique: true
  end
end
