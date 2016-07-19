class Wallet < ApplicationRecord
  belongs_to :user
  #include WalletModule
end
