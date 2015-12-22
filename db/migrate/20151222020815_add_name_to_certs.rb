class AddNameToCerts < ActiveRecord::Migration
  def change
    add_column :certs, :memo, :string
  end
end
