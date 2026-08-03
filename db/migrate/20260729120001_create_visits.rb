class CreateVisits < ActiveRecord::Migration[8.1]
  def change
    create_table :visits do |t|
      t.references :link, null: false, foreign_key: true, index: false
      t.string :referrer
      t.string :user_agent

      # A visit is a fact about a moment, so it is never updated.
      t.datetime :created_at, null: false
    end

    add_index :visits, [ :link_id, :created_at ]
  end
end
