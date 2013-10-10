class Polytag::Tag < ActiveRecord::Base
  self.table_name = "_polytags"
  has_many :_polytag_relations, class_name: 'Polytag::TagRelation', dependent: :destroy
  alias_method :relations, :_polytag_relations

  def tagged
    relations.tagged
  end
end
