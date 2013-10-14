class Polytag::TagRelation < ActiveRecord::Base
  self.table_name = :polytag_tag_relations
  belongs_to :polytag_tag, class_name: '::Polytag::Tag'
  belongs_to :tag, class_name: '::Polytag::Tag', foreign_key: :polytag_tag_id
  belongs_to :tagged, polymorphic: true

  # Cleanup tag if there are
  # no more relations left on the tag
  after_destroy do
    tag.reload
    if tag.relations.count < 0
      tag.destroy
    end
  end
end
