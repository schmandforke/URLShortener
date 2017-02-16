module Enigma

class CryptString
  def initialize(_str = nil, enc_alg = nil, key = nil, iv = nil)
    @enc_alg = enc_alg
    @key     = key
    @iv      = iv
    $log.debug{"ENIGMA:CryptString: initialized with algo: #{@enc_alg}, key: #{@key}, iv: #{@iv}"}
  end

  def encrypt64(str)
    $log.debug{"ENIGMA:CryptString: encrypting string: <#{str}>"}
    cip = OpenSSL::Cipher::Cipher.new(@enc_alg)
    cip.encrypt
    cip.key = @key
    cip.iv  = @iv

    es = cip.update(str)
    es << cip.final
    [es].pack('m')
  end
  alias_method :encrypt, :encrypt64

  def decrypt64(str)
    $log.debug{"ENIGMA:CryptString: decrypting string: <#{str}>"}
    cip = OpenSSL::Cipher::Cipher.new(@enc_alg)
    cip.decrypt
    cip.key = @key
    cip.iv  = @iv

    rs = cip.update(str.unpack('m').join)
    rs << cip.final

    rs
  end
  alias_method :decrypt, :decrypt64
end

class Machine
  def initialize
    @key = self.class.load_key
    $log.debug{"ENIGMA:Machine: initialized with Key: <#{@key.inspect}>"}
  end

  def encrypt(str, key = @key)
    $log.debug{"ENIGMA:Machine: encrypting some secrets"}
    key.encrypt64(str).delete("\n") unless str.nil? || str.empty?
  end

  def decrypt(str)
    if str.nil? || str.empty?
      raise "could not decrypt an empty secret, take my work serious man"
    else
      $log.debug{"ENIGMA:Machine: decrypt string: <#{str}>"}
      begin
        self.class.key.decrypt64(str).force_encoding('UTF-8')
      rescue
        raise "can not decrypt encrypted string"
      end
    end
  end

  def recrypt(str)
    $log.debug{"ENIGMA:Machine: recrypt string: <#{str}>"}
    return str if str.nil? || str.empty?
    decrypted_str =
      begin
        decrypt(str)
      rescue
        raise
      end
    encrypt(decrypted_str)
  end

  def self.encrypt(str)
    new.encrypt(str) if str
  end

  def self.decrypt(str)
    new.decrypt(str)
  end

  def self.key
    return load_key
  end

  def self.load_key
    $log.debug{"ENIGMA:Machine: try to load key: <#{$appConfig.keyFile}>"}
    begin
      ez_load("./config/#{$appConfig.keyFile}")
    rescue => e
      raise "could not find #{$appConfig.keyFile}"
    end
  end

  protected

  def self.ez_load(filename, recent = true)
    return filename if filename.respond_to?(:decrypt64)

    filename = File.expand_path(filename, ".") unless File.exist?(filename)
    if !File.exist?(filename)
      nil
    elsif recent
      EzCrypto::Key.load(filename)
    else
      params = YAML.load_file(filename)
      CryptString.new(nil, params[:algorithm], params[:key], params[:iv])
    end
  end
end
end
