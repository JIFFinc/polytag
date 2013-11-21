module Polytag
  module Concerns
    module TagOwner
      module AssociationExtensions
        module OwnedTags
          def get(tag, args = {})
            tag_group_query = ::Polytag.get(:tag_group, nil, args.merge(owner: proxy_association.owner))
            query = ::Polytag.get(:tag, nil, tag).where(polytag_tag_group_id: tag_group_query.select(:id))
            where(polytag_connections: {polytag_tag_group_id: query.select(:id)})
          end
          alias find get
        end
      end
    end
  end
end
