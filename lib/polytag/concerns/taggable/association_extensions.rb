module Polytag
  module Concerns
    module Taggable
      module AssociationExtensions
        def tag_group(args = {})
          includes(:tag_group).merge(::Polytag.get(tag_group: args[:tag_group], owner: args[:tag_group_owner]))
        end

        def no_tag_group
          where(polytag_tag_group_id: nil, owner_type: nil, owner_id: nil)
        end
      end
    end
  end
end
