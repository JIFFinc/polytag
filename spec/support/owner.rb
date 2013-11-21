class Owner < ActiveRecord::Base
  include Polytag::Concerns::TagOwner
end
