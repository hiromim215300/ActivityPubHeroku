class CreateNotes < ActiveRecord::Migration[5.1]
  def change
    create_table :notes do |t|
      t.text :content, null: false, default: nil
      t.references :actor, null: false, foreign_key: true
      t.string :federated_url

      t.timestamps
    end
  end
end
