module Polytag
  module Concerns
    module Owner
      class ModelHelpers
        def initialize(owner)
          @owner = owner
        end

        def new(group)
          ::Polytag.parse_data(group: group,
            final: :first_or_create,
            return: :group,
            owner: @owner
          )
        end
        alias add new
        alias create new

        def del(group)
          return false unless exist?(group)
          ::Polytag.parse_data(group: group,
            return: :group,
            owner: @owner,
            final: :first
          ).destroy
        end
        alias delete del
        alias remove del
        alias destroy del

        def exist?(group)
          group = ::Polytag.parse_data(group: group,
            return: :group,
            owner: @owner,
            final: :first
          ).is_a?(::Polytag::Group)
        rescue ActiveRecord::RecordNotFound
          false
        end

        def new_tag(tag, group = :default)
          ::Polytag.parse_data(group: group,
            final: :first_or_create,
            owner: @owner,
            return: :tag,
            tag: tag
          )
        end
        alias add_tag new_tag
        alias create_tag new_tag

        def del_tag(tag, group = :default)
          return false unless owns_tag?(group, tag)
          ::Polytag.parse_data(group: group,
            final: :first,
            owner: @owner,
            return: :tag,
            tag: tag
          ).destroy
        end
        alias delete_tag del_tag
        alias remove_tag del_tag
        alias destroy_tag del_tag

        def owns_tag?(tag, group = :default)
          ::Polytag.parse_data(group: group,
            final: :first,
            owner: @owner,
            return: :tag,
            tag: tag
          ).is_a?(::Polytag::Tag)
        rescue ActiveRecord::RecordNotFound
          false
        end
      end
    end
  end
end
