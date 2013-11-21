module Polytag
  class CantFindPolytagModel < ActiveRecord::RecordNotFound; end
  class NotTagOwnerOrTaggable < Exception; end
  class NotPolytagModel < Exception; end
  class NotTagOwner < Exception; end
  class NotTaggable < Exception; end
end
