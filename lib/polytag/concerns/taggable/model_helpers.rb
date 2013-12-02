module Polytag
  module Concerns
    module Taggable
      class ModelHelpers
        def initialize(owner)
          @owner = owner
        end

        def new(tag, args = {})
          ::Polytag.parse_data({
            final: :first_or_create,
            tagged: @owner,
            return: :tag,
            tag: tag
          }.merge(args))
        end
        alias add new
        alias create new

        def del(tag, args = {})
          return false unless exist?(tag, args)
          tag = ::Polytag.parse_data({
            tagged: @owner,
            final: :first,
            return: :tag,
            tag: tag
          }.merge(args)).destroy
        end
        alias delete del
        alias remove del
        alias destroy del

        def get(tag, args = {})
          return false unless exist?(tag, args)
          ::Polytag.parse_data({
            tagged: @owner,
            final: :first,
            return: :tag,
            tag: tag
          }.merge(args))
        end
        alias find get

        def exist?(tag, args = {})
          ::Polytag.parse_data({
            return: :connection,
            tagged: @owner,
            final: :first,
            tag: tag
          }.merge(args)).is_a?(::Polytag::Connection)
        rescue ActiveRecord::RecordNotFound
          false
        end
        alias has_tag? exist?

        def shares_with(other_model, tag, args = {})

          begin # Verify the tagability
            other_model = ::Polytag.get_tagged(other_model, :model)
          rescue ::Polytag::NotOwnerOrTaggable
            return false
          end

          # Run a check to ensure the two object share a tag
          other_model.tag.get(tag, args) == (tag = get(tag, args)) ? tag : false
        end

        def shares_with?(object, tag, args = {})
          shares_with(other_model, tag, args) ? true : false
        end

        def others_with_tag(tag = nil, args = {})
          # Get me the tag to search on
          tags = get(tag, args)

          if tags.is_a?(::Polytag::Tag)
            tags = tags.id
          else
            begin # Verify the tagability
              tagged = ::Polytag.get_tagged(@owner, :hash)
            rescue ::Polytag::NotOwnerOrTaggable
              return false
            end

            # Get all the tag ids from my tag connections
            tags = ::Polytag::Connection.where(tagged)
            tags = tags.select(:polytag_tag_id)
          end

          # Get a list of the connections that are shared through this tag
          ::Polytag::Connection.where(polytag_tag_id: tags)
        end
        alias associated_models others_with_tag

        def owned_by(owner, args = {})
          begin # Verify the tagability
            owner = ::Polytag.get_owner(owner)
          rescue ::Polytag::NotOwnerOrTaggable
            return false
          end

          # Get all the tags owned by owner
          @owner.tags.where(owner)
        end
      end
    end
  end
end
