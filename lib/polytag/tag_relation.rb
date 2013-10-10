class Polytag::TagRelation < ActiveRecord::Base
  self.table_name = "_polytag_relations"
  belongs_to :_polytag, class_name: 'Polytag::Tag'
  belongs_to :tagged, polymorphic: true
  alias_method :tag, :_polytag

  # Cleanup tag if there are no more relations let
  after_destroy do
    tag.reload
    if tag.relations.count < 0
      tag.destroy
    end
  end
end
