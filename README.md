# FieldStruct

`FieldStruct` provides a lightweight approach to having Ruby classes with metadata available about the attributes it holds..

# Basic

The most basic usage is for a simple ruby class:

```ruby
class BasicFriend < FieldStruct::Basic
  attribute :name
  attribute :age  
end

# Minimal
john = BasicFriend.new name: "John"
# => #<BasicFriend name="John">

john.name = "Steven"
# => #<BasicFriend name="Steven">

john.age = 35
# => #<BasicFriend name="Steven" age=35>
``` 


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'field_struct'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install field_struct

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/acima-credit/field_struct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
