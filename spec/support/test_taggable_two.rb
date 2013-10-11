class TestTaggableTwo < ActiveRecord::Base
  include Polytag

  after_initialize do
    tag_group owner: Owner.create!
  end
end
