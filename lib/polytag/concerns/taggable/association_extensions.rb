module Polytag
  module Concerns
    module Taggable
      module AssociationExtensions
        def tag_group(group = nil, args = {})
          if group.is_a?(Hash)
            args = group
            group = :ignore
          end

          group_ids = ::Polytag.parse_data({group: group, return: :group}.merge(args))
          where(polytag_group_id: group_ids.select(:id))
        end

        def no_tag_group
          where(polytag_group_id: nil, owner_type: nil, owner_id: nil)
        end

        def shared_models_through_tags
          Polytag::Connection.where(polytag_tag_id: select(:polytag_tag_id))
        end
      end
    end
  end
end
