class AddRevokeToCerts < ActiveRecord::Migration
  def change
    add_column :certs, :revoke_reason, :integer
    add_column :certs, :revoke_comment, :string
  end
end
