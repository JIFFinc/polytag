class Polytag::TagRelation < ActiveRecord::Base
  self.table_name = :polytag_tag_relations
  belongs_to :polytag_tag, class_name: '::Polytag::Tag'
  belongs_to :tagged, polymorphic: true
  alias_method :tag, :polytag_tag

  # Cleanup tag if there are
  # no more relations left on the tag
  after_destroy do
    tag.reload
    if tag.relations.count < 0
      tag.destroy
    end
  end
end
