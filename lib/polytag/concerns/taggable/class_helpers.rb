module Polytag
  module Concerns
    module Taggable
      module ClassHelpers
        def has_tag(tag, args = {})
          query = ::Polytag.get tag: tag,
            tag_group: args[:tag_group],
            owner: args[:tag_group_owner],
            foc: nil

          includes(:tags).where(polytag_connections: {polytag_tag_id: query.select(:id)})
        end
      end
    end
  end
end
