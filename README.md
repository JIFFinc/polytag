# Polytag

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'polytag'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install polytag

## Usage

Basic usage with a model

```ruby
class User < ActiveRecord::Base
  include Polytag::Concerns::Taggable
end

user = User.new

# Add a tag
user.tag.new('apple')
=> #<Polytag::Tag>

# Remove a tag
user.tag.del('apple')
=> true/false

# Check for tag
user.tag.has_tag?('apple')
=> true/false

# Get all tags
user.tags
=> #<ActiveRecord::Relation>
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
