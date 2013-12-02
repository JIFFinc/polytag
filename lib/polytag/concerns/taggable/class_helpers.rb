module Polytag
  module Concerns
    module Taggable
      module ClassHelpers
        def has_tag(tag, args = {})

          # Get the ids to filter on
          if tag.is_a?(::Polytag::Tag)
            ids = tag.id
          else
            query = ::Polytag.parse_data({tag: tag, return: :tag}.merge(args)).select(:id)

            ids = query.select(:id)
          end

          includes(:tags).where(polytag_connections: {polytag_tag_id: ids})
        end
      end
    end
  end
end
