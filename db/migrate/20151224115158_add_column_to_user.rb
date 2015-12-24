class AddColumnToUser < ActiveRecord::Migration
  def change
    add_column :users, :cert_serial_max, :integer, :default => 0;
  end
end
