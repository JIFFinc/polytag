module Polytag
  class CantFindPolytagModel < ActiveRecord::RecordNotFound; end
  class NotOwnerOrTaggable < Exception; end
  class NotPolytagModel < Exception; end
  class NotTaggable < Exception; end
  class NotOwner < Exception; end
end
