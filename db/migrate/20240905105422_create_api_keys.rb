class CreateApiKeys < ActiveRecord::Migration[7.2]
  def change
    create_table :api_keys, id: :uuid do |t|
      t.uuid :application_id, null: false
      t.string :api_secret, null: false

      t.timestamps
    end
    add_index :api_keys, :api_secret, unique: true
  end
end
