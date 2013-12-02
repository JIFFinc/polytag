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
          tags = [tags].compact
        end

        # Find/Create tags based on passed data
        tags.map! do |tag|
          if tag.is_a?(Hash) || tag.is_a?(Symbol) || tag.is_a?(String)
            tag = ::Polytag.parse_data(tag: tag)
          end

          if tag.is_a?(::Polytag::Connection)
            tag # Don't do anything (be careful)
            # I think this doing this might
            # disconnect the connection from another
            # model. So again be careful with this.
          elsif tag.is_a?(::Polytag::Tag)
            group = tag.try(:group)
            owner = group.try(:owner)

            results = ::Polytag.parse_data tag: tag,
              final: :first_or_initialize,
              process: :build_connection,
              owner: owner,
              group: group

            results[:connection]
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
