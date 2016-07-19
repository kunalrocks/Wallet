class WalletController < ApplicationController
  before_action :authenticate_user!, :except => [:enquiry, :get_refund]
  skip_before_action :verify_authenticity_token

  require 'wallet_module'
  require 'http_module'

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
      flash[:notice] = "wall2et already exists"
      redirect_to(:action => "index")
    else
      @wallet = current_user.build_wallet(:user_id => current_user.id)
      if @wallet.save
        record_activity("new account created", "NIL", "NIL")
        flash[:notice] = "wallet is successfully created"
        redirect_to(:action => "index")
      else
        render("index")
      end
    end
  end

  def record_activity(note, transaction_id, amount)
    @activity = ActivityLog.create(:user_id => current_user.id, :browser => request.env['HTTP_USER_AGENT'],
                                   :ip_address => request.env['REMOTE_ADDR'], :controller => controller_name,
                                   :transaction_id => transaction_id, :amount => amount, :action => action_name,
                                   :note => note)
  end

  def update
      @transactionId = WalletModule.generateTid()
      @signature = WalletModule.generateSignature(@transactionId, params[:redeem][:amount])
  end


  def redeem
    @wallet = Wallet.find_by(:user_id => current_user.id)

    if !@wallet
      flash[:notice] = "You have not created wallet yet"
      redirect_to(:action => "index")
    end
  end

  def get_response
      if params[:pgResponseCode].to_i == 3
        flash[:notice] = "transaction canceled"
        record_activity("transaction canceled", params[:merchantTransactionId], params[:amount])
        render('index')
      elsif params[:pgResponseCode].to_i == 1
        flash[:notice] = "transaction failed"
        record_activity("transaction failed", params[:merchantTransactionId], params[:amount])
        render('index')
      else
        @wallet = Wallet.where(user_id: current_user.id).first
        new_amount = @wallet.balance - params[:amount].to_i
        @wallet.update_attribute('balance', new_amount)
        record_activity("money debited from account", params[:merchantTransactionId], params[:amount])
        redirect_to(:action => 'index')
      end
  end

  def enquiry
      @transaction = ActivityLog.where(user_id: params[:id]).last
      @signature = WalletModule.generateSignatureForEnquiry(@transaction[:transaction_id])

      url = "https://betawallet.citruspay.com/rest/v1/orangepocket-service/enquiryWallet",
      options = {
          :body =>
          {
              "merchantAccessKey" => "VBR8O0HQICQK7CM03MIF",
              "merchantTransactionId" => "#{@transaction[:transaction_id]}",
              "autoReversal" => "true",
              "signature" => "#{@signature}"
          }.to_json,
      :headers =>
          {
              "Content-Type" => "application/json",
          }
      }

      resp = Http.http_post(url, options)
      resp = JSON.parse(resp.body)
      if resp['respCode'] && resp['respCode'] == "200"
        @response =  { success: true, response: { message: 'Enquiry Successful', response: resp, } }
      else
        @response =  { error: true, response: { message: resp['respMsg'], response: resp } }
      end
      render :json => @response
  end

  def refund

  end

  def get_refund
    @amount = params[:amount]
    @txn_id = params[:txn_id]
    @refund_id = WalletModule.generateTid()
    @signature = WalletModule.generateSignature(@txn_id, @amount)

    url = "https://betawallet.citruspay.com/rest/v1/orangepocketservice/refund",
    options = {
        :body =>
        {
            "merchantAccessKey" =>  "VBR8O0HQICQK7CM03MIF",
            "merchantTransactionId" => "#{@txn_id}",
            "amount" =>  "#{@amount}",
            "currency" => "INR",
            "merchantRefundTransactionId" =>  "#{@refund_id}",
            "signature" => "#{@signature}"
      }.to_json,
    :headers =>
        {
            "Content-Type" => "application/json",
            "Accept" => "application/json"
        }
    }

    resp = Http.http_post(url, options)
    resp = JSON.parse(resp.body)
    if resp['respCode'] && resp['respCode'] == "0"
      @response =  { success: true, response: { message: 'Refund Successful', response: resp, } }
      record_activity("refund successfull", @txn_id, @amount)
    else
      @response =  { error: true, response: { message: resp['respMsg'], response: resp } }
      record_activity("refund denied", @txn_id, @amount)
    end
    render :json => @response
  end

  private

  def wallet_params
    params.require(:wallet).permit(:balance)
  end

end
