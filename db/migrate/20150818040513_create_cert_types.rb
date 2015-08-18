class CreateCertTypes < ActiveRecord::Migration
  def change
    create_table :cert_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
