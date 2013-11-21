module Polytag
  module Concerns
    module Taggable
      class ModelHelpers
        def initialize(owner)
          @owner = owner
        end

        def new(tag, args = {})
          ::Polytag.get tag: tag,
            foc: :first_or_create,
            tag_group: args[:tag_group],
            owner: args[:tag_group_owner],
            tagged: @owner
        end
        alias add new
        alias create new

        def del(tag, args = {})
          return false unless exist?(tag, args)
          tag = ::Polytag.get tag: tag,
            tag_group: args[:tag_group],
            owner: args[:tag_group_owner],
            tagged: @owner,
            foc: :first

          tag.destroy
          true
        end
        alias delete del
        alias remove del
        alias destroy del

        def get(tag, args = {})
          return false unless exist?(tag, args)
          ::Polytag.get tag: tag,
            tag_group: args[:tag_group],
            owner: args[:tag_group_owner],
            tagged: @owner,
            foc: :first
        end
        alias find get

        def exist?(tag, args = {})
          tag = ::Polytag.get tag: tag,
            tag_group: args[:tag_group],
            owner: args[:tag_group_owner],
            tagged: @owner,
            foc: :first

          # Return the result
          tag.is_a?(::Polytag::Connection)
        rescue ActiveRecord::RecordNotFound
          false
        end
        alias has_tag? exist?
      end
    end
  end
end
