# External gems
require 'ezcrypto'
require 'base64'
require 'yaml'
require 'sinatra'
require 'json'
require 'logger'
require 'httpi'
require 'uri'
require 'rest-client'
require 'openssl'
# Module Extensions
require './helpers/init'
# Sinatra Routes
require './routes/init'
# Libaries
require './lib/init'

# load app config
$appConfig = Core::Config.new

# Variables
$0 = $appConfig.processName

# Setup Logging
Logger.class_eval { alias :write :'<<' }
$log = Logger.new(STDOUT)
$log.progname = Process.pid.to_s
case $appConfig.environment
  when /local/i then $log.level = Logger::DEBUG
  when /dev/i   then $log.level = Logger::INFO
  when /qa/i    then $log.level = Logger::INFO
  when /live/i  then $log.level = Logger::DEBUG
end

configure do
  HTTPI.log_level = :debug
  HTTPI.log       = true
  HTTPI.adapter   = :net_http
  set :logging, false
  set :environment, :"#{$appConfig.environment}"
  set :run, true
  set :bind, '0.0.0.0'
  set :lock, false
  set :port, $appConfig.appPort
  set :public_folder, './public'
  set :views, './views'
  set :version, "#{$appConfig.environment}/1.1.2"
  set :server, 'webrick'
  set :sessions, true
  set :protection, :except => :path_traversal
end

$log.info {"Started App"}
