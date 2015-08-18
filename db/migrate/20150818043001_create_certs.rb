class CreateCerts < ActiveRecord::Migration
  def change
    create_table :certs do |t|
      t.string :name
      t.datetime :get_at
      t.datetime :expire_at
      t.string :pin
      t.datetime :pin_get_at
      t.integer :user_id
      t.integer :cert_state_id
      t.integer :cert_type_id

      t.timestamps
    end
  end
end
