class AddDnToCerts < ActiveRecord::Migration
  def change
    add_column :certs, :dn, :string
  end
end
