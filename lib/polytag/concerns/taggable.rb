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

      def tag
        ModelHelpers.new(self)
      end
    end
  end
end
