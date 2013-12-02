require "polytag/version"
require "polytag/exceptions"

# Real work
require "polytag/connection"
require "polytag/tag"
require "polytag/group"

# Taggable Concerns
require "polytag/concerns/taggable/association_extensions"
require "polytag/concerns/taggable/class_helpers"
require "polytag/concerns/taggable/model_helpers"
require "polytag/concerns/taggable"

# Tag Owner Concerns
require "polytag/concerns/owner/association_extensions/owned_tags"
require "polytag/concerns/owner/association_extensions"
require "polytag/concerns/owner/class_helpers"
require "polytag/concerns/owner/model_helpers"
require "polytag/concerns/owner"

# Polytag Module
module Polytag
  class << self
    def parse_data(data = {})
      raise "Not a Hash" unless data.is_a?(Hash)

      # Prepare options
      options = {}
      options[:final]   = data.delete(:final)   || nil
      options[:search]  = data.delete(:search)  || nil
      options[:retry]   = data.delete(:retry)   || nil
      options[:process] = data.delete(:process) || nil
      options[:return]  = data.delete(:return)  || nil

      # Actual data
      real_data = {}
      real_data[:owner]   = data.delete(:owner)  || nil
      real_data[:tagged]  = data.delete(:tagged) || nil
      real_data[:group]   = data.delete(:group)  || nil
      real_data[:tag]     = data.delete(:tag)    || nil

      # Set additional data dependent on the case
      real_data[:group] ||= :default if real_data[:owner] && !real_data[:group]
      real_data[:owner]   = :none    if [:find, :guess].include?(data[:owner])

      # Cleanup real_data by removing nil values
      real_data = real_data.delete_if{ |k,v| v.nil? }

      # Get connections that we need
      get_owner(real_data)
      get_tagged(real_data)

      # Get the group and tag
      get_group(real_data, options)
      get_tag(real_data, options)

      # Create a connection to a tag if applicable
      create_connection(real_data, options)

      # Return the data requested
      return real_data[options[:return]] if options[:return]
      return real_data
    end
    alias get parse_data

    def get_owner(real_data, result = :hash)
      get_tagged(real_data, result, :owner)
    end

    def get_tagged(real_data, result = :hash, type = :tagged)
      real_data = {type => real_data} unless real_data.is_a?(Hash)
      return false unless real_data[type]
      klass = real_data[type]
      success = false

      # Parse hash to get get the real object
      # so we might continue
      if_a?(klass, Hash) do
        # Get keys to search through
        keys = klass.keys.map(&:to_s).uniq
        localized = keys.map{ |x| x.match(/^#{type}\_/) }

        # Get localized model
        if localized.uniq.include?(true)
          type  = klass["#{type}_type"] || klass["#{type}_type".to_sym]
          id    = klass["#{type}_id"]   || klass["#{type}_id".to_sym]
          klass = "#{type}".camelize.constantize.find(id)
        end

        # Get broader model
        if keys.map { |x| x == 'type' }.uniq.include?(true)
          type  = klass['type'] || klass[:type]
          id    = klass['id']   || klass[:id]
          klass = "#{type}".camelize.constantize.find(id)
        end
      end

      if_a?(klass, ActiveRecord::Base) do
        # Ensure we are good to go with this
        good     = if_a?(klass, Concerns::Taggable)
        if good || if_a?(klass, Concerns::Owner)
          success = true # Hell yah

          # Prepare the return result
          real_data[type] = case result
          when :hash
            {
              "#{type}_type".to_sym => "#{klass.class}",
              "#{type}_id".to_sym   => klass.id,
            }
          when :object, :model
            klass
          end
        else
          raise NotOwnerOrTaggable,
            "Not a Polytag::Concerns::Taggable or Polytag::Concerns::Owner."
        end
      end

      # Return the object in whatever form requested
      success ? real_data[type] : false
    end

    def get_group(real_data, options = {})
      return false unless real_data[:group]
      where = {}

      # If we have the tag group already just return
      if_a?(real_data[:group], Group) do |group|
        real_data[:owner] = group.owner
        get_owner(real_data)
        return group.id # Nothing else to process
      end

      # Handle string parsing and string ids
      if_a?(real_data[:group], String) do |group|
        is_id = string_id?(group)

        if options[:search] != :force && is_id
          options[:final!] = :first
          options[:retry]  = true
          real_data[:group] = Group.find(group)
          return get_group(real_data)
        else
          where.merge!(name: real_data[:group])
        end
      end

      # Group name search via symbol
      if_a?(real_data[:group], Symbol) do |name|
        where.merge!(name: name) unless name == :ignore
      end

      # Allow full hash searches
      if_a?(real_data[:group], Hash) do |group|
        where.merge!(group)
      end

      # Don't allow non-hash options for owner
      if_a?(real_data[:owner], Concerns::Owner) do
        get_owner(real_data)
      end

      # Get the data from the owner
      if_a?(real_data[:owner], Hash) do |owner|
        where.merge!(owner)
      end

      # Allow ownerless groups
      if_a?(real_data[:owner], NilClass) do
        where.merge!(owner_type: nil, owner_id: nil)
      end

      # Get the tag group and allow custom queries
      result = Group.where(where)
      result = yield(result) if block_given?

      # Run the final method (usually first or first_or_create)
      final  = options[:final!] || options[:final]
      result = result.__send__(final) if final
      real_data[:group] = result # Return the final result
    rescue ActiveRecord::RecordNotFound
      if options[:retry]
        options[:final!] = nil
        options[:search] = :force
        options[:retry]  = nil
        retry
      else
        raise
      end
    end

    def get_tag(real_data, options = {})
      return false unless real_data[:tag]
      where = {}

      # Allow processing of arrays
      if_a?(real_data[:tag], Array) do |tags|
        if tags.inject(true) { |o, v| o && string_id?(v) }
          where.merge!(id: tags.map(&:to_i))
        elsif tags.inject(true) { |o, v| o && (v.is_a?(String) || v.is_a?(Symbol))}
          where.merge!(name: tags.map(&:to_s))
        end
      end

      # Allow processing of fixnums
      if_a?(real_data[:tag], Fixnum) do |tag|
        real_data[:tag] = Tag.find(tag)
        return get_tag(real_data)
      end

      # Handle string parsing and string ids
      if_a?(real_data[:tag], String) do |tag|
        is_id = string_id?(tag)

        if options[:search] != :force && is_id
          options[:final!] = :first
          options[:retry]  = true
          real_data[:tag] = Tag.find(tag)
          return get_tag(real_data)
        else
          where.merge!(name: tag)
        end
      end

      # If we have the tag already just return
      if_a?(real_data[:tag], Tag) do |tag|
        real_data[:group] = tag.group
        get_group(real_data)
        return real_data[:tag].id # Nothing to process
      end

      # Group name search via symbol
      if_a?(real_data[:tag], Symbol) do |tag|
        where.merge!(name: tag)
      end

      # Allow full hash searches
      if_a?(real_data[:tag], Hash) do |tag|
        where.merge!(tag)
      end

      # Get additional search criteria from the tag group
      if_a?(real_data[:group], Group) do |group|
        where.merge!(polytag_group_id: group.id)
      end

      # Allow no group on the tag
      if_a?(real_data[:group], NilClass) do
        where.merge!(polytag_group_id: nil)
      end

      # Get the tag and allow custom queries
      result = Tag.where(where)
      result = yield(result) if block_given?

      # Run the final method (usually first or first_or_create)
      final  = options[:final!] || options[:final]
      result = result.__send__(final) if final
      real_data[:tag] = result # Return the final result
    rescue ActiveRecord::RecordNotFound
      if options[:retry]
        options[:final!] = nil
        options[:search] = :force
        options[:retry]  = nil
        retry
      else
        raise
      end
    end

    def create_connection(real_data, options = {})
      return false if ! real_data[:tagged] && options[:process] != :build_connection
      return false unless real_data[:tag]
      where = {}

      if options[:process] == :build_connection
        where.merge!(tagged_type: nil, tagged_id: nil)
      else
        # Require that we have hash arguments for the owners
        if_a?(real_data[:tagged], Concerns::Taggable) do
          get_tagged(real_data)
        end

        # Set the tagged items columns
        if_a?(real_data[:tagged], Hash) do
          where.merge!(real_data[:tagged])
        end

         # Require a tagged class to create a connection
        if_a?(real_data[:tagged], NilClass) do
          raise "Can't create a connection without a tagged."
        end
      end

      # Connect the tag to the connection
      if_a?(real_data[:tag], Tag) do |tag|
        real_data[:group] = tag.group
        get_group(real_data)
        where.merge!(polytag_tag_id: real_data[:tag].id)
      end

      # Require a tag to connect to the tagged class
      if_a?(real_data[:tag], NilClass) do
        raise "Can't connect a taggable to a tag without a tag."
      end

      # Apply a group to the connection conditions
      if_a?(real_data[:group], Group) do |group|
        real_data[:owner] = group.owner
        get_owner(real_data)
        where.merge!(polytag_group_id: real_data[:group].id)
      end

      # Allow tag connections without groups
      if_a?(real_data[:group], NilClass) do
        where.merge!(polytag_group_id: nil)
      end

      # Get the hash arguments for the owner
      if_a?(real_data[:owner], Concerns::Owner) do
        get_owner(real_data)
      end

      # Apply the hash arguments for the owner
      if_a?(real_data[:owner], Hash) do
        where.merge!(real_data[:owner])
      end

      # Allow ownerless tag connections
      if_a?(real_data[:owner], NilClass) do
        where.merge!(owner_type: nil, owner_id: nil)
      end

      # Get the tag and allow custom queries
      result = Connection.where(where)
      result = yield(result) if block_given?

      # Run the final method (usually first or first_or_create)
      final  = options[:final!] || options[:final]
      result = result.__send__(final) if final
      real_data[:connection] = result # Return the final result
    rescue ActiveRecord::RecordNotFound
      if options[:retry]
        options[:final!] = nil
        options[:retry]  = nil
        retry
      else
        raise
      end
    end

    private

    def if_a?(original_klass, *ancestors)

      # Ensure we have the actual classes to work with not objects
      klass = "#{original_klass.class}" == 'Class' ? "#{original_klass}" : "#{original_klass.class}"
      klass = klass.constantize

      # Check for ancestory
      result = ancestors.inject(true) do |value, ancestor|
        value && klass.ancestors.include?(ancestor)
      end

      # Yield on true
      if result && block_given?
        return yield(original_klass)
      end

      # Return the result
      result
    end

    def string_id?(data)
      (data.is_a?(String) && data.match(/^\d+$/)) || data.is_a?(Fixnum)
    end
  end
end
