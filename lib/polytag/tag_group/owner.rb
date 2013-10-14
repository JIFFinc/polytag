module Polytag::TagGroup::Owner
  def self.included(base)
    base.has_many :polytag_tag_groups, class_name: '::Polytag::TagGroup',
                                       as: :owner

    base.has_many :tag_groups, class_name: '::Polytag::TagGroup',
                               as: :owner

    base.has_many :polytag_owned_tags, class_name: '::Polytag::Tag',
                                       through: :polytag_tag_groups,
                                       source: :polytag_tag

    base.has_many :owned_tags, class_name: '::Polytag::Tag',
                               through: :polytag_tag_groups,
                               source: :polytag_tag
  end
end
