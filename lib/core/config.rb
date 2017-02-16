module Core
    class Config
      attr_accessor :processName, :appPort, :proxy, :environment, :timeformat, :keyFile

      def initialize
        config_file = nil
        config_file_name = 'app.yml'
        if FileTest.exists?(File.expand_path(File.join(File.dirname(__FILE__), "../../config/#{config_file_name}")))
          config_file = File.expand_path(File.join(File.dirname(__FILE__), "../../config/#{config_file_name}"))
        elsif FileTest.exists?("/etc/#{config_file_name}")
          config_file = "/etc/#{config_file_name}"
        else
          raise "can't find configuration file"
        end
        env = ENV['SHORTENER_ENVIRONMENT'] || "LOCAL"
        conf = YAML.load_file(config_file)[env]
        @environment        = env
        @processName        = conf['processName']
        @appPort            = conf['appPort']
        @proxy              = conf['proxy']
        @timeformat         = conf['timeformat']
        @keyFile            = conf['keyFile']
      end
    end
end
