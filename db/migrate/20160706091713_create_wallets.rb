class CreateWallets < ActiveRecord::Migration[5.0]
  def change
    create_table :wallets do |t|
      t.integer :balance, :default => 0
      t.integer :user_id, :null => false

      t.timestamps
    end
  end
end
