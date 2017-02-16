get '/decrypt/*' do
  deserializedHash = nil
  engima_object = Enigma::Machine.new
  encryptionString = params['splat'].first.gsub('-=O=-','//')
  $log.info{"ROUTE:/decrypt: got request to decrypt string: <#{encryptionString}>"}
  begin
    decryptedString = engima_object.decrypt(encryptionString)  
    deserializedHash = JSON.parse(decryptedString)
  rescue => e
    $log.error{"ROUTE:/decrypt: #{e}"}
    $log.error{"#{e.backtrace}"}
  end
  halt 406, "Could not decrypt provided Secret" if deserializedHash.nil?
  case deserializedHash["type"]
    when /proxy/i
      begin
        rest_call(deserializedHash["server"], $appConfig.proxy, 30, deserializedHash["username"], deserializedHash["password"], true).to_json
      rescue => e
        halt 500, "#{e}"
      end
    when /redirect/i
      redirect "#{deserializedHash["server"]}/#{deserializedHash["uri"]}"
    when /debug/i
      deserializedHash.to_json
    end
end

post '/encrypt' do
  encryptedString = nil
  engima_object = Enigma::Machine.new
  $log.info{"ROUTE:/encrypt: got request to encrypt some things"}
  begin
    payload = params.to_json
    halt 206, 'ERROR: mandatory parameters not set' if payload.nil?
    encryptedString = engima_object.encrypt(payload.to_s)
    $log.info{"ROUTE:/encrypt: encrypted data to: <#{encryptedString}>"}
    #erb :show, :locals => {data: encryptedString, request_object: request}
  rescue => e
    $log.error{"ROUTE:/encrypt: #{e}"}
    $log.error{"#{e.backtrace}"}
    halt 500, "ERROR: some strange things happens - this shit should not be productive" 
  end
  encryptedString.gsub('//','-=O=-')
end

get '/debug/*' do
  deserializedHash = nil
  engima_object = Enigma::Machine.new
  encryptionString = params['splat'].first.gsub('-=O=-','//')
  $log.info{"ROUTE:/debug: got request to decrypt string: <#{encryptionString}>"}
  begin
    decryptedString = engima_object.decrypt(encryptionString)
    deserializedHash = JSON.parse(decryptedString)
  rescue => e
    $log.error{"ROUTE:/debug: #{e}"}
    $log.error{"#{e.backtrace}"}
  end
  halt 406, "Could not decrypt provided Secret" if deserializedHash.nil?
  deserializedHash.to_json
end
