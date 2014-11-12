module VersionCake
  class VersionedRequest
    attr_reader :version, :extracted_version, :is_version_supported

    def initialize(request, config=VersionCake::Railtie.config.versioncake)
      @config = config
      derive_version(request)
    end

    def supported_versions
      @config.supported_versions(@version)
    end

    def is_latest_version?
      @version == @config.latest_version
    end

    def is_version_supported?
      @is_version_supported
    end

    def override_version(version)
      @version = version
      @is_version_supported = true
    end

    private

    def apply_strategies(request)
      version = nil
      @config.extraction_strategies.each do |strategy|
        version = strategy.extract(request)
        break unless version.nil?
      end
      version
    end

    def derive_version(request)
      begin
        @extracted_version = apply_strategies(request)
        @version = @extracted_version || @config.default_version || @config.latest_version
        @is_version_supported = @config.supports_version? @version
      rescue Exception
        @is_version_supported = false
      end
    end
  end
end
