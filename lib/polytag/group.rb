class Polytag::Group < ActiveRecord::Base
  self.table_name = :polytag_groups

  has_many :tag_connections,
    class_name: '::Polytag::Connection',
    foreign_key: :polytag_group_id

  has_many :tags,
    class_name: '::Polytag::Tag',
    foreign_key: :polytag_group_id,
    dependent: :destroy

  belongs_to :owner,
    polymorphic: true

  accepts_nested_attributes_for :tags

  validates_uniqueness_of :name, scope: [
    :owner_type,
    :owner_id
  ]
end
