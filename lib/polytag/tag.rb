class Polytag::Tag < ActiveRecord::Base
  self.table_name = :polytag_tags

  has_many :tag_connections,
    class_name: '::Polytag::Connection',
    foreign_key: :polytag_tag_id,
    dependent: :destroy

  belongs_to :group,
    class_name: '::Polytag::Group',
    foreign_key: :polytag_group_id
end
