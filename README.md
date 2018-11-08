# FieldStruct

[![Build Status](https://jenkins.smpl.ch/buildStatus/icon?job=github/field_struct/master)](https://jenkins.smpl.ch/job/github/job/field_struct/job/master/)

`FieldStruct` provides a lightweight approach to having typed structs in two flavors: `Value` and `Mutable`. 
Each attribute can:

* Have a type: `:string`, `:integer`, `:float`, `:time`
* Be `:required` (default) `:optional`
* Be `:strict` (default) or `:coercible`
* Have a `:default`
* Have a `:format` that it must follow
* Be one of many options (e.g. `:enum`)

## Usage

### `FieldStruct::Value` 

This class enforces validation on instantiation and provides values that cannot be mutated after creation.

```ruby
class Friend < FieldStruct::Value
  attribute :name, :string, :required
  attribute :age, :integer, :optional
  attribute :balance_owed, :float, :optional, :coercible, default: 0.0
  attribute :gamer_level, :integer, :optional, enum: [1,2,3], default: -> { 1 }  
  attribute :zip_code, :string, :optional, format: /^[0-9]{5}?$/  
end

# Minimal
john = Friend.new name: "John"
# => #<Friend name="John" age=nil balance_owed=0.0 gamer_level=1 zip_code=nil>

# Coercing string amount
eric = Friend.new name: "John", balance_owed: '$4.50'
# => #<Friend name="John" age=nil balance_owed=4.5 gamer_level=1 zip_code=nil>

# Ordered parameters 
leslie = Friend.new "Leslie", 25, gamer_level: 2 
# => #<Friend name="Leslie" age=25 balance_owed=0.0 gamer_level=2 zip_code=nil>

# Missing required fields
rosie = Friend.new age: 26
# => FieldStruct::BuildError: :name is required

# Invalid gamer level
carl = Friend.new "Carl", gamer_level: 11
# => FieldStruct::BuildError: :gamer_level is not included in list  

# Invalid zip code
melanie = Friend.new "Melanie", zip_code: '123'
# => FieldStruct::BuildError: :zip_code is not in a valid format  
``` 

### `FieldStruct::Mutable`
 
This class has all the same attribute options as `FieldStruct::Value` 
but it allows to instantiate invalid objects and modify the attributes after creation.

```ruby
class User < FieldStruct::Mutable
  attribute :username, :string
  attribute :password, :string
  attribute :team, :string, enum: %w{ A B C }
  attribute :last_login_at, :time, :optional
end

# A first attempt 
john = User.new 'john@company.com'
# => #<User username="john@company.com" password=nil team=nil last_login_at=nil>

# Is it valid? What errors do we have? 
[john.valid?, john.errors]
# => [false, [":password is required", ":team is required"]]

# Let's fix the first error: missing password 
john.password = 'some1234'
# => "some1234"

# Is it valid now? What errors do we still have? 
[john.valid?, john.errors]
# => [false, [":team is required"]]

# Let's fix the team
john.team = 'X'
# => "X"

# Are we valid now? Do we still have errors?
[john.valid?, john.errors]
# => [false, [":team is not included in list"]]

# Let's fix the team for real now
john.team = 'B'
# => "B"

# Are we finally valid now? Do we still have errors?
[john.valid?, john.errors]
# => [true, []]

# The final, valid product
john
# => #<User username="john@company.com" password="some1234" team="B" last_login_at=nil> 
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

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/field_struct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
