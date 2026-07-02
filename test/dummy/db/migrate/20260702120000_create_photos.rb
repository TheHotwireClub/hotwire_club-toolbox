class CreatePhotos < ActiveRecord::Migration[8.1]
  def change
    create_table :photos do |t|
      t.string :author
      t.boolean :favorite, null: false, default: false

      t.timestamps
    end
  end
end
