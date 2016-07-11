class WalletController < ApplicationController
  before_action :authenticate_user!

  layout 'application'

  def index
    @wallet = current_user.wallet
  end

  def new
    @wallet = current_user.wallet.new
  end

  def create
    @wallet = Wallet.find_by(:user_id => current_user.id)

    if @wallet
      flash[:notice] = "wallet already exists"
      redirect_to(:action => "index")
    else
      @wallet = current_user.build_wallet(:user_id => current_user.id)
      if @wallet.save
        record_activity("new account created")
        flash[:notice] = "wallet is successfully created"
        redirect_to(:action => "index")
      else
        render("index")
      end
    end
  end



  def record_activity(note)
    @activity = ActivityLog.new
    @activity.user_id = current_user.id
    @activity.browser = request.env['HTTP_USER_AGENT']
    @activity.ip_address = request.env['REMOTE_ADDR']
    @activity.controller = controller_name
    @activity.action = action_name
    #@activity.params = params.inspect
    @activity.note = note
    @activity.save
  end


  def update
    @wallet = Wallet.where(user_id: current_user.id).first
    new_amount = @wallet.balance - params[:redeem][:amount].to_i
    if new_amount < 0
      flash[:notice] = "you do not have enough balance in your account"
      redirect_to(:action => "redeem")
    else
      @wallet.update_attribute('balance', new_amount)
      record_activity("money debited from account")
      redirect_to(:action => "index")
    end
  end


  def redeem
    @wallet = Wallet.find_by(:user_id => current_user.id)

    if !@wallet
      flash[:notice] = "You have not created wallet yet"
      redirect_to(:action => "index")
    end
  end

  private

  def wallet_params
    params.require(:wallet).permit(:balance)
  end

end
