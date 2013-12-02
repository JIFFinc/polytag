module Polytag
  module Concerns
    module Owner
      module AssociationExtensions
        def default
          proxy_association.owner.tag_group.add(:default)
        end

        def get(group)
          where(name: "#{group}".strip).first
        end
      end
    end
  end
end
