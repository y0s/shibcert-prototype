class CreateCertStates < ActiveRecord::Migration
  def change
    create_table :cert_states do |t|
      t.string :name

      t.timestamps
    end
  end
end
