class CreateActivityLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :activity_logs, :force => true do |t|
      t.string "user_id"
      t.string "browser"
      t.string "ip_address"
      t.string "controller"
      t.string "action"
      t.string "params"
      t.string "note"
      t.timestamps
    end
  end
end
