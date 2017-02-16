def rest_call (url, proxy, timeout, user, pass, verbose)
  resource_config = Hash.new
  proxy.nil? or proxy.empty? ? (RestClient.proxy = nil) : (RestClient.proxy = proxy)
  headers = { :content_type => 'application/json', :accept => 'application/json'}
  case url
    when /^https$/i then resource_config = { :headers => headers, :verify_ssl => OpenSSL::SSL::VERIFY_NONE }
    when /^http$/i  then resource_config = { :headers => headers }
  end
  unless ( user.nil? or user.empty? ) and ( pass.nil? or pass.empty?)
    resource_config[:user] = user
    resource_config[:password] = pass
  end
  $log.debug {"RestCall.init : host: #{url}, proxy: #{proxy}"} if verbose
  servercall = RestClient::Resource.new("#{url}", resource_config, :timeout => timeout)
  $log.debug {"RestCall.init.inspect : #{servercall.inspect}"} if verbose
  begin 
    res = JSON.parse(servercall.get)
    $log.debug {"RestCall.response: got answer from restcall: #{res.inspect}"}
    return res
  rescue => e
    if defined?(e.http_body)
      $log.error {"RestCall.call : #{e} -- #{e.http_body}"}
      raise "#{e} (#{e.http_body})"
    else
      $log.error {"RestCall.call : #{e}"}
      raise e
    end
  end
end
