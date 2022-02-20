module SolidusImporter
  module Logger
    class << self
      def log_app_info(*what)
        Rails.logger.info("\t-<>- \e[37;41m#{what.join(" ")}\e[0m")
      end
    end
  end
end