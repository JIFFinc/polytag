require "polytag/version"
require "polytag/tag"

module Polytag
  def self.included(base)
    base.extend(ClassMethods)
    base.has_many :tags, through: :_polytag_relations, class_name: 'Polytag::Tag'
    base.has_many :_polytag_relations, as: :tagged, class_name: 'Polytag::TagRelation'
    base.__send__(:alias_method, :tag_relations, :_polytag_relations)
  end

  def add_tag(tag)
    tags.first_or_initialize(name: tag, category: self.class.polytag_category)
  end

  def add_tag!(tag)
    tags.first_or_create(name: tag, category: self.class.polytag_category)
  end

  def remove_tag!(tag)
    tag_id = tags.where(name: tag, category: self.class.polytag_category).first.id
    tag_relations.where("_polytags.id = ?", tag_id).destroy
  end

  module ClassMethods

    # Set the category for the model
    def polytag_category(category)
      category ? @category = category : @category
    end

    # Get records on a single tag
    def has_tag(tag)
      tag_query = ["_polytags.name = '#{tag}'"]
      tag_query << "_polytags.category = '#{category}'" if category

      tag = Polytag::Tag.select('_polytag_id.id').where(tag_query.join('&&')).first.id
      includes(:polytag_relations).where("_polytag_relations._polytag_id = '#{id}'")
    end

    # Get records against multiple tags
    def has_tags(*tags)
      tag_query = ["_polytags.name IN (?)"]
      tag_query << "_polytags.category = '#{category}'" if category

      tags = Polytag::Tag.select('_polytag_id.id').where(tag_query.join('&&'), tags).map(&:id)
      includes(:polytag_relations).where("_polytag_relations._polytag_id IN (?)", tags).group("#{table_name}.id")
    end

    # @TODO: Implement results must be connected to all tags
  end
end
