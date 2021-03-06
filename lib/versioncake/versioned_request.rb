module VersionCake
  class VersionedRequest
    attr_reader :version, :extracted_version, :is_version_supported

    def initialize(request, config, version_override=nil)
      @config = config
      derive_version(request, version_override)
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

    private

    def apply_strategies(request)
      version = nil
      @config.extraction_strategies.each do |strategy|
        version = strategy.extract(request)
        break unless version.nil?
      end
      version
    end

    def derive_version(request, version_override)
      if version_override
        @version = version_override
        @is_version_supported = true
      else
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
end
