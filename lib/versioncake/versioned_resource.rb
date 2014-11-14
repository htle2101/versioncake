module VersionCake
  class VersionedResource

    def initialize(uri, supported_versions)

    end

    def supports_version?

    end

    def version_is_obsolete?

    end

  end

  class VersionedResources
    def initialize
      @versioned_resources = []
    end

    def find_by_path(uri)
      @versioned_resources.each do |versioned_resource|
        versioned_resource.match uri
      end
    end
  end
end

# valid_resources = {
#     %r{users} => {
#         obsolute: 2,
#         deprecated: 3,
#         supported: 4,
#         rewrite_uri: 'user'
#     },
#     %r{user} => {
#         supported: (5..LATEST)
#     }
# }
#
# v1/users => 404
# v2/users => 410 (GONE)
# v3/users => 'v3/user' with warning
# v4/users => 'v4/user'
# v5/users => 404
# v5/user => 'v5/user'
# v6/user => 'v6/user'


module VersionCake
  class VersioningMiddleware

    def initialize(app)
      @app = app
      @versioned_resources = VersionCake::VersionedResources.new
    end

    def call(env)
      req = Rack::Request.new env

      # is this a versioned resource?
      if resource = @versioned_resources.find_by_path(req.path)
        versioned_request = VersionCake::VersionedRequest.new(req)
        if !versioned_request.is_version_supported?
          # handle no support version 500 bad request?
        elsif resource.supports_version? versioned_request.version
          # set the version in env
          # rewrite the uri
        elsif resource.version_is_obsolete? versioned_request.version
          # not here anymore, 410 GONE response
        else
          # versioned resource that doesn't support this version 404
        end
      end

      @app.call(env)
    end
  end
end