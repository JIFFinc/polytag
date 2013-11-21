class Polytag::Tag < ActiveRecord::Base
  self.table_name = :polytag_tags

  has_many :tag_connections,
    class_name: '::Polytag::Connection',
    foreign_key: :polytag_tag_id

  belongs_to :tag_group,
    class_name: '::Polytag::TagGroup',
    foreign_key: :polytag_tag_group_id
end
