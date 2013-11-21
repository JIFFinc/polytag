class Polytag::TagGroup < ActiveRecord::Base
  self.table_name = :polytag_tag_groups

  has_many :tag_connections,
    class_name: '::Polytag::Connection',
    foreign_key: :polytag_tag_group_id

  has_many :tags,
    class_name: '::Polytag::Tag',
    foreign_key: :polytag_tag_group_id

  belongs_to :owner,
    polymorphic: true
end
