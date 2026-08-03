class CreateLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :links do |t|
      t.string  :url,          null: false
      t.string  :slug,         null: false
      t.integer :visits_count, null: false, default: 0

      t.timestamps
    end

    add_index :links, :slug, unique: true
  end
end
