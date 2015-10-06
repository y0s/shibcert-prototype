class AddStatePurposeTypeToCert < ActiveRecord::Migration
  def change
    add_column :certs, :state, :integer
    add_column :certs, :purpose_type, :integer
  end
end
