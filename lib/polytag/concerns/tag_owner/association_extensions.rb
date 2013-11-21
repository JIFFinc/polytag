module Polytag
  module Concerns
    module TagOwner
      module AssociationExtensions
        def default
          where(name: :default).first
        end

        def get(group)
          where(name: "#{group}".strip).first
        end
      end
    end
  end
end
