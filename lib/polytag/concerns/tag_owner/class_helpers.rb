module Polytag
  module Concerns
    module TagOwner
      module ClassHelpers
        def has_tag_group(group)
          query = ::Polytag.get foc: nil,
            tag_group: group

          includes(:tag_groups).where(polytag_tag_groups: {id: query.select(:id)})
        end

        def has_tag(tag, group = nil)
          if group
            tag_group_query = ::Polytag.get(:tag_group, nil, group).select(:id)
            query = ::Polytag.get(:tag, nil, tag).where(polytag_tag_group_id: tag_group_query)
          else
            query = ::Polytag.get(:tag, nil, tag)
          end

          includes(:tag_groups).where(polytag_tag_groups: {id: query.select(:id)})
        end
      end
    end
  end
end
