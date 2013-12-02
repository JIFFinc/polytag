module Polytag
  module Concerns
    module Owner
      module AssociationExtensions
        module OwnedTags
          def get(*tags)
            # Get the arguments of the end of the tags
            args = tags.size > 1 && tags.last.is_a?(Hash) ? tags.pop : {}

            # Get the tags from polytag (hopefully by id)
            tags = ::Polytag.parse_data({
              tag: tags.flatten.compact,
              group: :ignore,
              owner: :none,
              return: :tag
            }.merge(args))

            # Return all connections matching the tag_group owner and tag id criteria.
            where(polytag_connections: {polytag_tag_id: tags.select(:id)})
          end
          alias find get
        end
      end
    end
  end
end
