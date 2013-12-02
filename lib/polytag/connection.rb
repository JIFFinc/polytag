class Polytag::Connection < ActiveRecord::Base
  self.table_name = :polytag_connections

  class << self
    def get_owners(type = nil, id = nil)
      get_tagged(type, id, :owner)
    end

    def get_tagged(type = nil, id = nil, polytype = :tagged)
      scope = type ? tagged(type, id, polytype) : self

      # If we have multiples of the same type of connection then
      # go group by the type and id columns in order to not return duplicates
      scope = scope.group("polytag_connections.#{polytype}_type, polytag_connections.#{polytype}_id")

      # Allow block access to save ram
      if block_given?
        scope.each do |tag_connection|
          yield(tag_connection.__send__(polytype))
        end
      else
        scope.map(&polytype)
      end
    end

    def owner(type, id = nil)
      tagged(type, id, :owner)
    end

    def tagged(type, id = nil, polytype = :tagged)
      # Allow passing arrays for the query data
      type = [type] unless type.is_a?(Array)
      id   = [id]   unless id.is_a?(Array)
      type.map!{ |x| "#{x}".camelize }

      # Remove nil values
      type = type.compact
      id   = id.compact

      # Query arguments
      arguments = {}
      arguments["#{polytype}_type".to_sym] = type
      arguments["#{polytype}_id".to_sym] = id unless id.empty?

      # Eager load the polymorphics
      where(arguments)
    end
  end

  belongs_to :tag,
    class_name: '::Polytag::Tag',
    foreign_key: :polytag_tag_id

  belongs_to :group,
    class_name: '::Polytag::Group',
    foreign_key: :polytag_group_id

  belongs_to :owner,
    polymorphic: true

  belongs_to :tagged,
    polymorphic: true

  delegate :name,
    to: :tag

  # Destroy the tag if it is no longer in use
  after_destroy do
    if ! tag.group && tag.tag_connections.count < 1
      tag.destroy
    end
  end
end
