class CreateActors < ActiveRecord::Migration[5.1]
  def change
    create_table :actors do |t|
      t.string :name
      t.string :federated_url
      t.string :server
      t.string :inbox_url
      t.string :outbox_url
      t.string :followers_url
      t.string :followings_url
      t.bigint :user_id
      t.references :user, null: true, foreign_key: true

      t.timestamps
      t.index :federated_url, unique: true
    end
    remove_index :actors, :user_id
    add_index :actors, :user_id, unique: true
  end
end
