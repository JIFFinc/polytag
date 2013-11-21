module Polytag
  module Concerns
    module TagOwner
      class ModelHelpers
        def initialize(owner)
          @owner = owner
        end

        def new(group)
          ::Polytag.get tag_group: group,
            foc: :first_or_create,
            owner: @owner
        end
        alias add new
        alias create new

        def del(group)
          return false unless exist?(group)
          group = ::Polytag.get tag_group: group,
            owner: @owner,
            foc: :first

          group.destroy
          true
        end
        alias delete del
        alias remove del
        alias destroy del

        def exist?(group)
          group = ::Polytag.get tag_group: group,
            owner: @owner,
            foc: :first

          # Return the result
          group.is_a?(::Polytag::TagGroup)
        rescue ActiveRecord::RecordNotFound
          false
        end

        def new_tag(tag, group = nil)
          ::Polytag.get tag_group: group,
            foc: :first_or_create,
            owner: @owner,
            tag: tag
        end
        alias add_tag new_tag
        alias create_tag new_tag

        def del_tag(tag, group = nil)
          return false unless owns_tag?(group, tag)
          tag = ::Polytag.get tag_group: group,
            owner: @owner,
            foc: :first,
            tag: tag

          tag.destroy
          true
        end
        alias delete_tag del_tag
        alias remove_tag del_tag
        alias destroy_tag del_tag

        def owns_tag?(tag, group = nil)
          tag = ::Polytag.get tag_group: group,
            owner: @owner,
            foc: :first,
            tag: tag

          # Return the result
          tag.is_a?(::Polytag::Tag)
        rescue ActiveRecord::RecordNotFound
          false
        end
      end
    end
  end
end
