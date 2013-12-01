module Polytag
  module Concerns
    module TagOwner
      extend ActiveSupport::Concern

      module ClassMethods
        include ClassHelpers
      end

      included do
        has_many :tag_groups,
          class_name: '::Polytag::TagGroup',
          dependent: :destroy,
          as: :owner do
          include AssociationExtensions
        end

        has_many :owned_tags,
          class_name: '::Polytag::Connection',
          dependent: :destroy,
          as: :owner do
          include AssociationExtensions::OwnedTags
        end
      end

      # Handle the adding
      # of tag groups via attributes
      def tag_groups=(tag_groups)
        # Require tag groups to be an array
        unless tag_groups.is_a?(Array)
          tag_groups = [tag_groups]
        end

        # Find/Create tag groups based on passed data
        tag_groups.map! do |tag_group|
          if tag_group.is_a?(::Polytag::TagGroup)
            tag_group # Don't change anything this is all we need
          elsif tag_group.is_a?(Hash)
            Polytag::TagGroup.new(tag_group)
          elsif tag_group.is_a?(Symbol) || tag_group.is_a?(String)
            Polytag::TagGroup.new(name: tag_group)
          end
        end

        # Hell yah go add those bitches
        super(tag_groups.compact)
      end

      def tag_group
        ModelHelpers.new(self)
      end
    end
  end
end
