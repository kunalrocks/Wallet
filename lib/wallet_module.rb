module WalletModule

  def self.generateTid
    uid = SecureRandom.base64(11)
    [ '/', '=', '+' ].each { | c | uid.gsub!(c, '') }
    uid.upcase!
    return uid
  end

  def self.hmac_sha1(data, secret)
    require 'base64'
    require 'cgi'
    require 'openssl'
    hmac = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha1'), secret.encode("ASCII"), data.encode("ASCII"))
    return hmac
  end

  def self.generateSignature(transactionId, amount)
    #Need to change with your Secret Key
    @secret_key = "d2c679ec2e756a2cea492259d8881a076ff7bc79"
    #Need to change with your Access Key
    @access_key = "VBR8O0HQICQK7CM03MIF"
    #Should be unique for every transaction
    @txn_id = transactionId
    #Need to change with your Order Amount
    @amount = amount
    @currency = 'INR'
    @data_string = "merchantAccessKey=#{@access_key}&merchantTransactionId=#{@txn_id}&amount=#{@amount}&currency=#{@currency}"
    @securitySignature = hmac_sha1(@data_string,@secret_key) # signature generated
    @amount = {'value' => amount, 'currency' => 'INR'}
    return @securitySignature

  end

  def self.generateSignatureForEnquiry(transactionId)
    #Need to change with your Secret Key
    @secret_key = "d2c679ec2e756a2cea492259d8881a076ff7bc79"
    #Need to change with your Access Key
    @access_key = "VBR8O0HQICQK7CM03MIF"
    #Should be unique for every transaction
    @txn_id = transactionId
    @data_string = "merchantAccessKey=#{@access_key}&merchantTransactionId=#{@txn_id}"
    @securitySignature = hmac_sha1(@data_string,@secret_key) # signature generated
    return @securitySignature
  end

end