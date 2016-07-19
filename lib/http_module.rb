module Http

  def self.http_post(url, options)
    begin
      resp = HTTParty.post(url, options)
    end
    return resp
  end

  def self.http_put(url, options)
    begin
      resp = HTTParty.put(url, options)
    end
    return resp
  end

  def self.http_delete(url, options)
    begin
      resp = HTTParty.delete(url, options)
    end
    return resp
  end

  def self.http_get(url, options)
    begin
      resp = HTTParty.get(url, options)
    end
    return resp
  end

end