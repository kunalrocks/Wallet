class MvcController < ApplicationController
  require 'wallet_module'
  require 'http_module'

  skip_before_action :verify_authenticity_token

  def index

  end

  def authenticate
    url = "https://sboxmvc.citruspay.com/merchant/auth"

    options = {
        :body =>
      {
          "access_key" => "VBR8O0HQICQK7CM03MIF",
          "secret_key" => "d2c679ec2e756a2cea492259d8881a076ff7bc79"
      }.to_json,
      :headers =>
      {
          "Content-Type" => "application/json"
      }
    }

    resp = Http.http_post(url, options)
    resp = JSON.parse(resp.body)
    if resp['auth_token']
      $auth_token = resp['auth_token']
      @response = {success: true, response: {message: 'authentication successful', response: resp}}
    else
      @response = {success: false, response: {message: 'authentication failed', response: resp}}
    end
    render :json => @response
  end

  def create
        url = "https://sboxmvc.citruspay.com/merchant/virtualcrr/"
        options = {
            :body =>
            {
                    "currency_name" => "#{params[:currency_name]}",
                    "valid_from" => "#{params[:valid_from]}",
                    "valid_to" => "#{params[:valid_to]}",
                    "numberofmonths" => params[:numberofmonths],
                    "numberofdays" => params[:numberofdays],
                    "max_unique_users" => params[:max_unique_users],
                    "max_amount_per_user" => params[:max_amount_per_user],
                    "max_amount_total" => params[:max_amount_total],
                    "issue_multiple_per_user" => "#{params[:issue_multiple_per_user]}",
                    "max_issue_per_user" => params[:max_issue_per_user],
                    "max_issue_all" =>  params[:max_issue_all],
                    "max_users" => params[:max_users],
                    "currency" => "#{params[:currency]}",
                    "currency_ratio" => params[:currency_ratio],
                    "partial_redeem" => "#{params[:partial_redeem]}",
                    "min_red_amt" => params[:min_red_amt],
                    "max_red_amt" => params[:max_red_amt],
                    "exclusive_flag" => params[:exclusive_flag],
                    "priority_order" => params[:priority_order]
            }.to_json,

        :headers =>
            {
                "auth_token" => "#{$auth_token}",
                "Content-Type" => "application/json"
            }
        }
        resp = Http.http_post(url, options)
        resp = JSON.parse(resp.body)
        if resp['currency_code']
          $currency_code = resp['currency_code']
          @response = {success: true, response: {message: 'currency created', response: resp}}
        else
          @response = {success: false, response: {message: 'error occurred', response: resp}}
        end
        render :json => @response
  end


  def update_mvc
      url = "https://sboxmvc.citruspay.com/merchant/virtualcrr/"
      options = {
          :body =>
          {
              "currency_code" => "#{params[:currency_code]}",
              "valid_from" => "#{params[:valid_from]}",
              "valid_to" => "#{params[:valid_to]}",
              "numberofmonths" => params[:numberofmonths],
              "numberofdays" => params[:numberofdays],
              "max_unique_users" => params[:max_unique_users],
              "max_amount_per_user" => params[:max_amount_per_user],
              "max_amount_total" => params[:max_amount_total],
              "issue_multiple_per_user" => "#{params[:issue_multiple_per_user]}",
              "max_issue_per_user" => params[:max_issue_per_user],
              "max_issue_all" =>  params[:max_issue_all],
              "max_users" => params[:max_users],
              "currency" => "#{params[:currency]}",
              "currency_ratio" => params[:currency_ratio],
              "partial_redeem" => "#{params[:partial_redeem]}",
              "min_red_amt" => params[:min_red_amt],
              "max_red_amt" => params[:max_red_amt],
              "exclusive_flag" => params[:exclusive_flag]
          }.to_json,

      :headers =>
          {
              "auth_token" => "#{$auth_token}",
              "Content-Type" => "application/json"
          }
      }
      resp = Http.http_put(url, options)
      resp = JSON.parse(resp.body)
      if resp['currency_code']
        @response = {success: true, response: {message: 'currency updated', response: resp}}
        $currency_code = resp['currency_code']
      else
        @response = {success: false, response: {message: 'error occurred', response: resp}}
      end
      render :json => @response
end

  def update_priority
     url = "https://sboxmvc.citruspay.com/merchant/updatepriority/"
      options = {
          :body =>
          {
              "currency_code" => "#{params[:currency_code]}",
              "priority_order" => params[:priority_order]
          }.to_json,
          :headers =>
          {
              "auth_token" => "#{$auth_token}",
              "Content-Type" => "application/json"
          }
      }
     resp = Http.http_put(url, options)
     resp = JSON.parse(resp.body)
     if resp['currency_code']
       @response = {success: true, response: {message: 'priority updated', response: resp}}
     else
       @response = {success: false, response: {message: 'error occurred', response: resp}}
     end
     render :json => @response
  end

  def deactivate_mvc
      url = "https://sboxmvc.citruspay.com/merchant/virtualcrr/"
      options = {
          :body =>
          {
              "currency_code" => "#{params[:currency_code]}",
              "currency_active" => params[:currency_active],
              "issue_active" => params[:issue_active]
          }.to_json,
      :headers =>
          {
              "auth_token" => "#{$auth_token}",
              "Content-Type" => "application/json"
          }
      }
      resp = Http.http_delete(url, options)
      resp = JSON.parse(resp.body)
      if resp['currency_code']
        @response = {success: true, response: {message: 'currency deactivated', response: resp}}
      else
        @response = {success: false, response: {message: 'error occurred', response: resp}}
      end
      render :json => @response
  end

  def issue_coupon
    @ref_id = WalletModule.generateTid()
      url = "https://sboxmvc.citruspay.com/merchant/coupon/issue/"
      options = {
          :body =>
          {
              "currency_code" => "#{$currency_code}",
              "mobile" => "#{params[:mobile]}",
              "valid_from" => "#{params[:valid_from]}",
              "valid_to" => "#{params[:valid_to]}",
              "numberofmonths" => params[:numberofmonths],
              "numberofdays" => params[:numberofdays],
              "amount" => params[:amount],
              "issue_ref" => "#{@ref_id}"

          }.to_json,
      :headers =>
          {
              "auth_token" => "#{$auth_token}",
              "Content-Type" => "application/json"
          }
      }
    resp = Http.http_post(url, options)
    resp = JSON.parse(resp.body)
    if resp['coupon_code']
      @response = {success: true, response: {message: 'coupon issued', response: resp}}
      @coupon = Coupon.create(:currency_code => $currency_code, :coupon_code => resp['coupon_code'], :mobile => params[:mobile],
                              :valid_from => params[:valid_from], :valid_to => params[:valid_to],
                              :amount => params[:amount], :issue_ref => @ref_id, :user_id => "1")
    else
      @response = {success: false, response: {message: 'error occurred', response: resp}}
    end
    render :json => @response
  end

  def rollback_coupon
    url = "https://sboxmvc.citruspay.com/merchant/rollback/issue/"
    options = {
        :body =>
        {
            "coupon_code" => "#{params[:coupon_code]}",
            "issue_ref" => "#{params[:issue_ref]}"

        }.to_json,
    :headers =>
        {
            "auth_token" => "#{$auth_token}",
            "Content-Type" => "application/json"
        }
    }
    resp = Http.http_post(url, options)
    resp = JSON.parse(resp.body)
    if resp['issue_ref']
      @response = {success: true, response: {message: 'coupon rollback done', response: resp}}
    else
      @response = {success: false, response: {message: 'error occurred', response: resp}}
    end
    render :json => @response
  end

  def fetch_balance
    url = "https://sboxmvc.citruspay.com/merchant/fetchbalance/"
    options = {
        :body =>
        {
            "currency_code" => "#{params[:currency_code]}",
            "mobile" => "#{params[:mobile]}"

        }.to_json,
    :headers =>
        {
            "auth_token" => "#{$auth_token}",
            "Content-Type" => "application/json"
        }
    }
    resp = Http.http_post(url, options)
    resp = JSON.parse(resp.body)
    if resp['curr']
      @response = {success: true, response: {message: 'currency fetched', response: resp}}
    else
      @response = {success: false, response: {message: 'error occurred', response: resp}}
    end
    render :json => @response
  end

  def fetch_all_balance
    url = "https://sboxmvc.citruspay.com/merchant/fetchcurrbalance/"
    options = {
        :body =>
        {
            "mobile" => "#{params[:mobile]}"

        }.to_json,
    :headers =>
        {
            "auth_token" => "#{$auth_token}",
            "Content-Type" => "application/json"
        }
    }
    resp = Http.http_post(url, options)
    resp = JSON.parse(resp.body)
    render :json => resp
  end

  def redeem_coupon
    @trans_id = WalletModule.generateTid()
   url = "https://sboxmvc.citruspay.com/merchant/coupon/redeem/"
   options = {
       :body =>
        {
            "currency_code" => "#{params[:currency_code]}",
            "mobile" => "#{params[:mobile]}",
            "amount" => params[:amount],
            "trans_id" => "#{@trans_id}",
            "comment" => "#{params[:comment]}"

        }.to_json,
    :headers =>
        {
            "auth_token" => "#{$auth_token}",
            "Content-Type" => "application/json"
        }
   }
    resp = Http.http_post(url, options)
    resp = JSON.parse(resp.body)
    if resp['trans_id']
      @response = {success: true, response: {message: 'coupon redeemed', response: resp}}
    else
      @response = {success: false, response: {message: 'error occurred', response: resp}}
    end
    render :json => @response
  end

  def redeem_currency
    @trans_id = WalletModule.generateTid()
    url = "https://sboxmvc.citruspay.com/merchant/redeem/"
        options = {
          :body =>
              {
                  "mobile" => "#{params[:mobile]}",
                  "amount" => params[:amount],
                  "trans_id" => "#{@trans_id}",
                  "comment" => "#{params[:comment]}"

              }.to_json,
          :headers =>
              {
                  "auth_token" => "#{$auth_token}",
                  "Content-Type" => "application/json"
              }
        }
    resp = Http.http_post(url, options)
    resp = JSON.parse(resp.body)
    if resp['trans_id']
      @response = {success: true, response: {message: 'coupon redeemed', response: resp}}
    else
      @response = {success: false, response: {message: 'error occurred', response: resp}}
    end
    render :json => @responses
  end

  def fetch_transactions
    url = "https://sboxmvc.citruspay.com/merchant/coupon/enquiry/"
        options = {
            :body =>
                {
                    "currency_code" => "#{params[:currency_code]}",
                    "coupon_code" => "#{params[:coupon_code]}",
                    "from_date" => "#{params[:from_date]}",
                    "to_date" => "#{params[:to_date]}",
                    "mobile" => "#{params[:mobile]}",
                    "trans_id" => "#{params[:trans_id]}"
                }.to_json,
            :headers =>
                {
                    "auth_token" => "#{$auth_token}",
                    "Content-Type" => "application/json"
                }
        }
    resp = Http.http_post(url, options)
    resp = JSON.parse(resp.body)
    render :json => resp
  end

  def fetch_coupons
    url = "https://sboxmvc.citruspay.com/merchant/fetchcoupon/"
        options = {
            :body =>
                {
                    "currency_code" => "#{params[:currency_code]}",
                    "coupon_code" => "#{params[:coupon_code]}",
                    "from_date" => "#{params[:from_date]}",
                    "to_date" => "#{params[:to_date]}",
                    #"ccuid" => "#{params[:ccuid]}",
                    "issue_ref" => "#{params[:issue_ref]}"
                }.to_json,
            :headers =>
                {
                    "auth_token" => "#{$auth_token}",
                    "Content-Type" => "application/json"
                }
        }
    resp = Http.http_post(url, options)
    resp = JSON.parse(resp.body)
    render :json => resp
  end

  def fetch_one_mvc
    url = "https://sboxmvc.citruspay.com/merchant/fetchmvc/"
        options = {
            :body =>
                {
                    "currency_code" => "#{params[:currency_code]}"
                }.to_json,
            :headers =>
                {
                    "auth_token" => "#{$auth_token}",
                    "Content-Type" => "application/json"
                }
        }
    resp = Http.http_post(url, options)
    resp = JSON.parse(resp.body)
    render :json => resp
  end


  def fetch_all_mvc
    url = "https://sboxmvc.citruspay.com/merchant/fetchallmvc/"
        options = {
            :headers =>
                {
                    "auth_token" => "#{$auth_token}",

                }
        }
    resp = Http.http_get(url, options)
    resp = JSON.parse(resp.body)
    render :json => resp
  end

  def rollback_redeem
    url = "https://sboxmvc.citruspay.com/merchant/rollback/redeem/"
    options = {
        :body =>
            {
                "trans_id" => "#{params[:trans_id]}",
                "amount" => params[:amount],
                "comment" => "#{params[:comment]}"
            }.to_json,
        :headers =>
            {
                "auth_token" => "#{$auth_token}",
                "Content-Type" => "application/json"
            }
    }
    resp = Http.http_post(url, options)
    resp = JSON.parse(resp.body)
    render :json => resp
  end

  def fetch_refund
    url = "https://sboxmvc.citruspay.com/merchant/fetchrefund/"
        options = {
            :body =>
                {
                    "currency_code" => "#{params[:currency_code]}",
                    "coupon_code" => "#{params[:coupon_code]}",
                    "from_date" => "#{params[:from_date]}",
                    "to_date" => "#{params[:to_date]}",
                    "mobile" => "#{params[:mobile]}",
                    "trans_id" => "#{params[:trans_id]}",
                    "issue_ref" => "#{params[:issue_ref]}"
                }.to_json,
            :headers =>
                {
                    "auth_token" => "#{$auth_token}",
                    "Content-Type" => "application/json"
                }
        }
    resp = Http.http_post(url, options)
    resp = JSON.parse(resp.body)
    render :json => resp
  end

end
