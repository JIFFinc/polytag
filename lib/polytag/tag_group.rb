class Polytag::TagGroup < ActiveRecord::Base
  self.table_name = :polytag_tag_groups
  has_many :polytag_tag, class_name: '::Polytag::Tag',
                         dependent: :destroy

  belongs_to :owner, polymorphic: true
  alias_method :tag, :polytag_tag

  # Cleanup tag if there are
  # no more relations left on the tag
  after_destroy do
    tag.reload
    if tag.relations.count < 0
      tag.destroy
    end
  end

  class << self
    def search_by_hash(hash = {})
      return self if hash.empty?
      conditions = {}

      # Query by owner information
      if hash[:owner]
        conditions.merge!(owner_type: "#{hash[:owner].class}")
        conditions.merge!(owner_id: hash[:owner].id)
      else
        if hash[:owner_type]
          conditions.merge!(owner_type: "#{hash[:owner_type]}")
          conditions.merge!(owner_id: hash[:owner_id]) if hash[:owner_id]
        end
      end

      # Query by tag group name
      conditions.merge!(name: "#{hash[:name]}") if hash[:name]
      where(conditions)
    end

    def find_by_hash(hash = {})
      search_by_hash(hash).first
    end
  end
end
