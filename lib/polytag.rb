require "polytag/version"
require "polytag/exceptions"

# Real work
require "polytag/connection"
require "polytag/tag"
require "polytag/tag_group"

# Taggable Concerns
require "polytag/concerns/taggable/association_extensions"
require "polytag/concerns/taggable/class_helpers"
require "polytag/concerns/taggable/model_helpers"
require "polytag/concerns/taggable"

# Tag Owner Concerns
require "polytag/concerns/tag_owner/association_extensions/owned_tags"
require "polytag/concerns/tag_owner/association_extensions"
require "polytag/concerns/tag_owner/class_helpers"
require "polytag/concerns/tag_owner/model_helpers"
require "polytag/concerns/tag_owner"

# Polytag Module
module Polytag
  class << self
    def get(type = :tag, foc = nil, data = {})
      force_name_search = false
      retried = false

      # Allow hashes to be passed
      if type.is_a?(Hash) || type.is_a?(ActiveRecord::Base)
        data = type
        type = nil
        foc  = nil
      elsif foc.is_a?(Hash) || foc.is_a?(ActiveRecord::Base)
        data = foc
        foc  = nil
      end

      # Reject nil or false data keys
      # also grab the foc value
      if data.is_a?(Hash)
        data = data.delete_if { |k, v| v.nil? || v == false }
        foc  = data.delete(:foc) if data.has_key?(:foc)
        data[:tag_group] = :default if data[:owner] && ! data[:tag_group]
      end

      # Ensure that we are processing the right data if the data comes in in a unexpected way
      if data.is_a?(Hash) && data.keys.size == 1 && [:tag, :tag_group].include?(data.keys.first)
        type = data.keys.first
        data = data[data.keys.first]
      end

      # Return the model if the model passed matches
      if data.is_a?(ActiveRecord::Base)
        return data if data.instance_of?(Tag) && (type ? type == :tag : true)
        return data if data.instance_of?(TagGroup) && (type ? type == :tag_group : true)
        return data if data.instance_of?(Connection) && (type ? type == :connection : true)
        raise NotAPolytagModel, "#{data.inspect} is not a Polytag model in the requested form."
      elsif data.is_a?(String) || data.is_a?(Symbol)
        data = "#{data}".strip
      end

      # Handle how the results are returned
      if data.is_a?(Hash) && data.keys.sort == [:owner, :tag, :tag_group, :tagged]

        # Get the tag owner
        tag_owner = get_tag_owner_or_taggable(:hash, data[:owner])

        # Get the tag group
        querydata = {owner: tag_owner, tag_group: data[:tag_group], foc: foc}
        tag_group = get(:tag_group, foc || :first, querydata)

        # Get the tag
        querydata = {tag: data[:tag], tag_group: tag_group, foc: foc}
        tag       = get(:tag, foc || :first, querydata)

        # Create the data we are using to create the connection
        querydata = tag_owner.merge foc: foc,
          polytag_tag_id: tag.id,
          polytag_tag_group_id: tag_group.id,
          tagged: data[:tagged]

        __connection_processor(querydata)
      elsif data.is_a?(Hash) && data.keys.sort == [:tag, :tag_group, :tagged]

        # Get the tag group
        querydata = {tag_group: data[:tag_group], foc: foc}
        tag_group = get(:tag_group, foc || :first, querydata)

        # Get the tag
        querydata = {tag: data[:tag], tag_group: tag_group, foc: foc}
        tag       = get(:tag, foc || :first, querydata)

        # Create the data we are using to create the connection
        querydata = {}.merge foc: foc,
          polytag_tag_group_id: tag_group.id,
          polytag_tag_id: tag.id,
          tagged: data[:tagged]

        __connection_processor(querydata)
      elsif data.is_a?(Hash) && data.keys.sort == [:tag, :tagged]

        # Handle attaching tags that are already intantiated
        if data[:tag].is_a?(Tag)
          tag = data[:tag]

          # Add the tag group and owner
          if tag_group = tag.tag_group
            data.merge(tag_group: tag_group)
            if owner = tag_group.owner
              data.merge!(owner: owner)
            end
          end

          # Try again
          return get(type, foc, data)
        end

        # Get the tag
        querydata = {tag: data[:tag], foc: foc}
        tag = get(:tag, foc || :first, querydata) do |ar|
          if __numerical_string_id?(data[:tag])
            ar
          else
            ar.where(polytag_tag_group_id: nil)
          end
        end

        # If we expected a result and we don't have one raise
        raise CantFindPolytagModel if foc && ! tag

        # Create the data we are using to create the connection
        querydata = {}.merge foc: foc,
          polytag_tag_group_id: nil,
          polytag_tag_id: tag.id,
          tagged: data[:tagged]

        __connection_processor(querydata)
      elsif data.is_a?(Hash) && data.keys.sort == [:owner, :tag, :tag_group]

        # Get the tag owner
        tag_owner = get_tag_owner_or_taggable(data[:owner])

        # Get the tag group
        querydata = {owner: tag_owner, tag_group: data[:tag_group], foc: foc}
        tag_group = get(:tag_group, foc || :first, querydata)

        # Get the tag
        querydata = {tag: data[:tag], tag_group: tag_group, foc: foc}
        tag       = get(:tag, foc, querydata)

        return tag
      elsif data.is_a?(Hash) && data.keys.sort == [:owner, :tag_group]
        # Get the tag group with owner
        tag_owner = get_tag_owner_or_taggable(:hash, data[:owner])

        get(:tag_group, foc, data[:tag_group]) do |ar|
          ar.where(tag_owner)
        end
      elsif data.is_a?(Hash) && data.keys.sort == [:tag, :tag_group]

        # Get the tag with tag group
        tag_group = get(:tag_group, foc || :first, data[:tag_group])

        get(:tag, foc, data[:tag]) do |ar|
          ar.where(polytag_tag_group_id: tag_group.id)
        end
      elsif type && data.is_a?(Array) && __numerical_string_ids?(data)
        result = const_get("#{type}".camelize).where(id: data)
        result = yield(result) if block_given?
        return result
      elsif type && ! force_name_search && __numerical_string_id?(data)

        result = const_get("#{type}".camelize).where(id: data.to_i)
        result = yield(result) if block_given?
        result = result.first if foc
        return result
      elsif type && (force_name_search || data.is_a?(String))

        result = const_get("#{type}".camelize).where(name: data)
        result = yield(result) if block_given?
        result = result.__send__(foc) if foc
        return result
      else
        raise CantFindPolytagModel, "Can't find a polytag model with #{data.inspect}."
      end
    rescue ActiveRecord::RecordNotFound => e
      raise e if e.instance_of?(CantFindPolytagModel) || retried
      force_name_search = true
      retried = true
      foc = :first
      retry
    end

    def tag_group_owner?(owner = {}, raise_on_error = false)
      owner = get_polymorphic(owner)
      return true if __inherits(data.class, ActiveRecord::Base, Concerns::TagOwner)
      raise NotTagOwner, "This model #{owner.inspect} is not a polytag tag owner."
    rescue NotTagOwner, NotTagOwnerOrTaggable => e
      raise e unless raise_on_error
      false
    end

    def get_tag_owner_or_taggable(result = :object, data = {})
      result_type = nil

      # Set the return result type
      if [:taggable, :tag_owner].include?(result)
        result_type = result
        result = :object
      end

      # Ensure result is is always set
      if result.is_a?(Hash) || result.is_a?(ActiveRecord::Base)
        data   = result
        result = :object
      end

      if data.is_a?(Hash)
        data = if data.keys.sort == [:id, :type]
          data[:type].camelize.constantize.find(data[:id])
        elsif data.keys.sort == [:owner_id, :owner_type]
          data[:owner_type].camelize.constantize.find(data[:owner_id])
        elsif data.keys.sort == [:tagged_id, :tagged_type]
          data[:tagged_type].camelize.constantize.find(data[:tagged_id])
        end
      end

      # The class we need to test
      dclass = data.class

      # Raise if not the type of object we want in return
      if result_type && ! __inherits(dclass, ActiveRecord::Base, const_get('Concerns').const_get("#{result_type}".camelize))
        raise const_get("Not#{result_type.camelize}"), "The model #{data.inspect} doess not concern Polytag::Concerns::#{result_type.camelize}."
      end

      # Ensure that the model we return is a taggable or tag owner
      if __inherits(dclass, ActiveRecord::Base, Concerns::TagOwner) || __inherits(dclass, ActiveRecord::Base, Concerns::Taggable)

        # Return hash options for the type
        if result == :hash
          if __inherits(dclass, ActiveRecord::Base, Concerns::TagOwner)
            return {owner_type: "#{dclass}", owner_id: data.id}
          elsif __inherits(dclass, ActiveRecord::Base, Concerns::Taggable)
            return {tagged_type: "#{dclass}", tagged_id: data.id}
          end
        end

        # Return the raw object
        return data if result == :object
      end

      # Raise if not a taggable or tag owner object
      raise NotTagOwnerOrTaggable, "The model #{data.inspect} is not a polytag tag owner or taggable model."
    end

    private

    def __inherits(klass, *ancestors)
      ancestors.inject(true) do |result, ancestor|
        result && klass.ancestors.include?(ancestor)
      end
    end

    def __connection_processor(data)
      foc = data.delete(:foc)

      # Get the item we are trying to tag
      taggable  = get_tag_owner_or_taggable(:hash, data.delete(:tagged))

      # Get the connection where statement
      connection_hash = data.merge(taggable)

      # Find the object and create it if applicable
      result = Connection.where(connection_hash)
      result = result.__send__(foc) if foc
      result
    end

    def __numerical_string_id?(data)
      (data.is_a?(String) && data.match(/^\d+$/)) || data.is_a?(Fixnum)
    end

    def __numerical_string_ids?(data)
      data.inject(true) do |result, value|
        result && __numerical_string_id?(value)
      end
    end
  end
end
