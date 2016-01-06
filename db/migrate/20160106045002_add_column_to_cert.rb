class AddColumnToCert < ActiveRecord::Migration
  def change
    add_column :certs, :req_seq, :integer
  end
end
