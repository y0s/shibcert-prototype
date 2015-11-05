class AddSerialnumberToCerts < ActiveRecord::Migration
  def change
    add_column :certs, :serialnumber, :string
  end
end
