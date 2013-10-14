class Polytag::Tag < ActiveRecord::Base
  self.table_name = :polytag_tags
  belongs_to :polytag_tag_group, class_name: '::Polytag::TagGroup'
  has_many :polytag_tag_relations, class_name: '::Polytag::TagRelation',
                                   foreign_key: :polytag_tag_id,
                                   dependent: :destroy

  alias_method :tag_group, :polytag_tag_group
  alias_method :relations, :polytag_tag_relations

  # Indiscrimanetly get
  # the tagged models
  def tagged
    polytag_tag_relations.tagged
  end

  # Cleanup group if there are
  # no more tags left on the group
  after_destroy do
    polytag_tag_group.reload
    if polytag_tag_group.tags.count < 0
      polytag_tag_group.destroy
    end
  end
end
