module Polytag
  module Concerns
    module TagOwner
      module AssociationExtensions
        module OwnedTags
          def get(*tags)

            # Get the tags that are requested if they are also in a tag group from the owner
            tag_group_ids = proxy_association.owner.tag_groups.select(:id)
            tags = ::Polytag.get(:tag, nil, tags.size == 1 ? tags.first : tags) do |ar|
              ar.where(polytag_tag_group_id: tag_group_ids)
            end

            # Return all connections matching the tag_group owner and tag id criteria.
            where(polytag_connections: {polytag_tag_id: tags.select(:id)})
          end
          alias find get
        end
      end
    end
  end
end
