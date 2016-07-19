class CreateCoupons < ActiveRecord::Migration[5.0]

  def change
    create_table :coupons do |t|
      t.string :currency_code
      t.string :coupon_code
      t.string :mobile, :default => "8756320983"
      t.string :valid_from
      t.string :valid_to
      t.integer :amount
      t.string :issue_ref, :null => false
      t.integer :user_id, :null => false

      t.timestamps
    end
  end
end
