module Polytag
  module Concerns
    module Owner
      extend ActiveSupport::Concern

      module ClassMethods
        include ClassHelpers
      end

      included do
        has_many :tag_groups,
          class_name: '::Polytag::Group',
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
      def tag_groups=(groups)
        # Require tag groups to be an array
        unless groups.is_a?(Array)
          groups = [groups].compact
        end

        # Find/Create tag groups based on passed data
        groups.map! do |group|
          if group.is_a?(::Polytag::Group)
            group # Don't change anything this is all we need
          elsif group.is_a?(Hash) || group.is_a?(Symbol) || group.is_a?(String)
            ::Polytag.parse_data(group: group)
          end
        end

        # Hell yah go add those bitches
        super(groups.compact)
      end

      def tag_group
        ModelHelpers.new(self)
      end
    end
  end
end
