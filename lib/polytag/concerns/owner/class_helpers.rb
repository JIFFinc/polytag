module Polytag
  module Concerns
    module Owner
      module ClassHelpers
        def has_tag_group(group)
          query = ::Polytag.parse_data(group: group, owner: :none, return: :group)
          includes(:tag_groups).where(polytag_groups: {id: query.select(:id)})
        end

        def has_tag(tag, group = nil)
          query = ::Polytag.parse_data(tag: tag, group: group ? group : :ignore, return: :tag)
          includes(:tag_groups).where(polytag_groups: {id: query.select(:id)})
        end
      end
    end
  end
end
