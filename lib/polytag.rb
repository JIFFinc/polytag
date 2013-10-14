require "polytag/version"
require "polytag/tag"
require "polytag/tag_group"
require "polytag/tag_group/owner"
require "polytag/tag_relation"

module Polytag
  def self.included(base)
    base.extend(ClassMethods)
    base.has_many :polytag_tag_relations, class_name: '::Polytag::TagRelation',
                                          as: :tagged

    base.has_many :tag_relations, class_name: '::Polytag::TagRelation',
                                  as: :tagged

    base.has_many :polytag_tags, class_name: '::Polytag::Tag',
                                 through: :polytag_tag_relations

    base.has_many :tags, class_name: '::Polytag::Tag',
                         through: :polytag_tag_relations,
                         source: :polytag_tag
  end

  def tag_group(_tag_group = nil)
    @__polytag_tag_group_hash__ ||= {}

    if _tag_group
      @__polytag_tag_group_hash__.merge!(_tag_group)
      @__polytag_tag_group__ = Polytag::TagGroup.search_by_hash(@__polytag_tag_group_hash__).first_or_create
    else
      @__polytag_tag_group_hash__ = {} if _tag_group.is_a?(Hash) && _tag_group.empty?
      @__polytag_tag_group__
    end
  end

  def add_tag(tag, _tag_group = {})
    polytag_tags << polytag_tags.where(name: tag, polytag_tag_group_id: tag_group(_tag_group).try(&:id)).first_or_initialize
  end

  def add_tag!(tag, _tag_group = {})
    polytag_tags << polytag_tags.where(name: tag, polytag_tag_group_id: tag_group(_tag_group).try(&:id)).first_or_create
  end

  def add_tags(*_tags)
    _tag_group = _tags.pop if _tags.last.is_a?(Hash)
    _tags.map { |x| add_tag(x, _tag_group || {}) }
  end

  def add_tags!(*_tags)
    _tag_group = _tags.pop if _tags.last.is_a?(Hash)
    _tags.map { |x| add_tag!(x, _tag_group || {}) }
  end

  def remove_tag!(tag, _tag_group = {})
    tag_id = polytag_tags.where(name: tag, polytag_tag_group_id: tag_group(_tag_group).try(&:id)).first.try(:id)
    tag_relations.where("polytag_tag_relations.polytag_tag_id = ?", tag_id).delete_all
  end

  module ClassMethods

    # Get records with tags
    def has_tags(*tags)
      includes(polytag_tag_relations: :polytag_tag).references(:polytag_tags).where("polytag_tags.name IN (?)", tags).group("#{table_name}.id")
    end

    alias_method :has_tag, :has_tags

    def in_tag_group(_tag_group = {})
      if _tag_group[:group_ids]
        tag_groups = _tag_group[:group_ids]
      else
        tag_groups = Polytag::TagGroup.select('polytag_tag_groups.id').search_by_hash(_tag_group).map{ |tg| tg.try(:id) }.flatten
      end

      return tag_groups if _tag_group[:multi]

      includes(polytag_tag_relations: :polytag_tag).references(:polytag_tags).where('polytag_tags.polytag_tag_group_id IN (?)', tag_groups)
    end

    def in_tag_groups(*tag_groups)
      tag_groups = tag_groups.map{ |tg| in_tag_group(tg.merge(multi: true)) }.flatten.compact
      in_tag_group(group_ids: tag_groups)
    end

    # @TODO: Implement results must be connected to all tags
  end
end
