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

      def tag_group
        ModelHelpers.new(self)
      end
    end
  end
end
