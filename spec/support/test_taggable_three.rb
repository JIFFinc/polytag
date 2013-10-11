class TestTaggableThree < ActiveRecord::Base
  include Polytag

  after_initialize do
    tag_group_owner = Owner.create!
    tag_group owner_type: tag_group_owner.class.name, owner_id: tag_group_owner.id
  end
end
