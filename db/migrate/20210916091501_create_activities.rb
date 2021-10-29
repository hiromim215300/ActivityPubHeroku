class CreateActivities < ActiveRecord::Migration[5.1]
  def change
    create_table :activities do |t|
      t.references :entity, polymorphic: true, null: false
      t.string :action, null: false, default: nil
      t.references :actor, null: false, foreign_key: true

      t.timestamps
    end
  end
end
