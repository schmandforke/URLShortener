get '/' do
  erb :landing, :locals => { :requestObject => request }
end
