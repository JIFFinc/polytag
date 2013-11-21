class Taggable < ActiveRecord::Base
  include Polytag::Concerns::Taggable
end
