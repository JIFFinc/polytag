module Polytag
  module Concerns
    module Taggable
      module ClassHelpers
        def has_tag(tag, args = {})

          # Get the ids to filter on
          if tag.is_a?(::Polytag::Tag)
            ids = tag.id
          else
            query = ::Polytag.get tag: tag,
              tag_group: args[:tag_group],
              owner: args[:tag_group_owner],
              foc: nil

            ids = query.select(:id)
          end

          includes(:tags).where(polytag_connections: {polytag_tag_id: ids})
        end
      end
    end
  end
end
