module Polytag
  module Concerns
    module Taggable
      extend ActiveSupport::Concern

      module ClassMethods
        include ClassHelpers
      end

      included do
        has_many :tags,
          class_name: '::Polytag::Connection',
          dependent: :destroy,
          as: :tagged do
          include AssociationExtensions
        end
      end

      # Handle the adding
      # of tags via attributes
      def tags=(tags)
        # Require tags to be an array
        unless tags.is_a?(Array)
          tags = [tags]
        end

        # Find/Create tags based on passed data
        tags.map! do |tag|
          if tag.is_a?(::Polytag::Tag) || tag.is_a?(::Polytag::Connection)
           tag # Don't change anything this is all we need
          elsif tag.is_a?(Hash)
            tag[:owner] = tag.delete(:tag_group_owner)
            ::Polytag.get(tag.merge(foc: :first_or_create))
          elsif tag.is_a?(Symbol) || tag.is_a?(String)
            ::Polytag.get(tag: tag)
          end
        end

        # Generate the connection objects
        tags.map! do |tag|
          if tag.is_a?(::Polytag::Connection)
            tag # Don't change anything this is all we need
          elsif tag.is_a?(::Polytag::Tag)
            # Data to help build the connection
            tag_group   = tag.try(:tag_group)
            group_owner = tag_group.try(:owner)

            # Build the connection
            ::Polytag::Connection.new tag: tag,
              tag_group: tag_group,
              owner: group_owner
          end
        end

        # Hell yah go add those bitches
        super(tags.compact)
      end

      def tag
        ModelHelpers.new(self)
      end
    end
  end
end
