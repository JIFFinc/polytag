class Polytag::Connection < ActiveRecord::Base
  self.table_name = :polytag_connections

  class << self
    def get_tagged(type = nil, id = nil)
      r = tagged(type, id) if type

      # Allow block access to save ram
      if block_given?
        r.each do |connection|
          yield(connection.tagged)
        end
      else
        r.map(&:tagged)
      end
    end

    def get_owners(type = nil, id = nil)
      r = owner(type, id) if type

      # Allow block access to save ram
      if block_given?
        r.each do |connection|
          yield(connection.owner)
        end
      else
        r.map(&:owner)
      end
    end

    def tagged(type, id = nil)
      arguments = {tagged_type: "#{type}".camelize}
      arguments[:tagged_id] = id if id
      where(arguments)
    end

    def owner(type, id = nil)
      arguments = {owner_type: "#{type}".camelize}
      arguments[:owner_id] = id if id
      where(arguments)
    end
  end

  belongs_to :tag,
    class_name: '::Polytag::Tag',
    foreign_key: :polytag_tag_id

  belongs_to :tag_group,
    class_name: '::Polytag::TagGroup',
    foreign_key: :polytag_tag_group_id

  belongs_to :owner,
    polymorphic: true

  belongs_to :tagged,
    polymorphic: true

  delegate :name,
    to: :tag

  # Destroy the tag if it is no longer in use
  after_destroy do
    if ! tag.tag_group && tag.tag_connections.count < 1
      tag.destroy
    end
  end
end
