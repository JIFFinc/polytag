class Polytag::Connection < ActiveRecord::Base
  self.table_name = :polytag_connections

  belongs_to :tag,
    class_name: '::Polytag::Tag',
    foreign_key: :polytag_tag_id

  belongs_to :tag_group,
    class_name: '::Polytag::TagGroup',
    foreign_key: :polytag_tag_group_id

  belongs_to :owner,
    polymorphic: true

  belongs_to :tagged,
    polymorphic: true

  delegate :name,
    to: :tag

  # Destroy the tag if it is no longer in use
  after_destroy do
    if ! tag.tag_group && tag.tag_connections.count < 1
      tag.destroy
    end
  end
end
