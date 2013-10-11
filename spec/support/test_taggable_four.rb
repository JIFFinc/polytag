class TestTaggableFour < ActiveRecord::Base
  include Polytag

  after_initialize do
    tag_group owner: Owner.create!, name: 'Employees'
  end
end
