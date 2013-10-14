module Polytag::TagGroup::Owner
  def self.included(base)
    base.has_many :polytag_tag_groups, as: :owner, class_name: '::Polytag::TagGroup'
    base.has_many :polytag_owned_tags, through: :polytag_tag_groups, source: :polytag_tag, class_name: '::Polytag::Tag'
    base.__send__(:alias_method, :tag_groups, :polytag_tag_groups) unless base.method_defined?(:tag_relations)
    base.__send__(:alias_method, :owned_tags, :polytag_owned_tags) unless base.method_defined?(:owned_tags)
  end
end
