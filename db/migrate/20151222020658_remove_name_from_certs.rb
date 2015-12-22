class RemoveNameFromCerts < ActiveRecord::Migration
  def change
    remove_column :certs, :name, :string
  end
end
