# FieldStruct

`FieldStruct` provides a lightweight approach to having typed structs in three flavors: `Flexible`, `Strict` 
and `Mutable`.

It is heavily based on [ActiveModel](https://edgeguides.rubyonrails.org/active_model_basics.html) and adds 
syntactic sugar to make the developer experience much more enjoyable. 


## Attributes   

All structs can be defined with multiple attributes. Each attribute can:

* Have a known type: `:string`, `:integer`, `:float`, `:date`,` :time`, `:boolean`, etc.
* Have a new type like `:array`, `:currency` or a nested `FieldStruct` itself. 
* Be `:required` or `:optional` (default)
* Have a `:default` value or proc.
* Have a `:format` that it must follow.
* Be one of many options (e.g. `:enum`)
* Have Have any number of ActiveRecord-like validations.

You can use the `required` and `optional` aliases to `attribute` to skip using the `:required` and `:optional` argument. 

## Usage

### `FieldStruct::StrictValue` 

This class enforces validation on instantiation and provides values that cannot be mutated after creation.

```ruby
class Friend < FieldStruct.strict
  required :name, :string
  optional :age, :integer
  optional :balance_owed, :currency, default: 0.0
  optional :gamer_level, :integer, enum: [1,2,3], default: -> { 1 }  
  optional :zip_code, :string, format: /\A[0-9]{5}?\z/  
end

# Minimal
john = Friend.new name: "John"
# => #<Friend name="John" balance_owed=0.0 gamer_level=1>

# Can't modify once created 
john.name = "Steven" 
# FrozenError: can't modify frozen Hash

# Coercing string amount
eric = Friend.new name: "John", balance_owed: '$4.50'
# => #<Friend name="John" balance_owed=4.5 gamer_level=1>

# Missing required fields - throws an exception
rosie = Friend.new age: 26
# => FieldStruct::BuildError: :name can't be blank

# Invalid gamer level - throws an exception
carl = Friend.new name: "Carl", gamer_level: 11
# => FieldStruct::BuildError: :gamer_level is not included in the list  

# Invalid zip code - throws an exception
melanie = Friend.new name: "Melanie", zip_code: '123'
# => FieldStruct::BuildError: :zip_code is invalid  
``` 

### `FieldStruct::FlexibleValue` 

This class does NOT enforce validation on instantiation and provides values that cannot be mutated after creation.

```ruby
class Friend < FieldStruct.flexible
  required :name, :string
  optional :age, :integer
  optional :balance_owed, :currency, default: 0.0
  optional :gamer_level, :integer, enum: [1,2,3], default: -> { 1 }  
  optional :zip_code, :string, format: /\A[0-9]{5}?\z/  
end

# Minimal
john = Friend.new name: "John"
# => #<Friend name="John" balance_owed=0.0 gamer_level=1>
john.valid?
# => true

# Can't modify once created 
john.name = "Steven" 
# FrozenError: can't modify frozen Hash

# Missing required fields - not valid
rosie = Friend.new age: 26
# => #<Friend name=nil age=26 balance_owed=0.0 gamer_level=1 zip_code=nil>
rosie.valid?
# => false
rosie.errors.to_hash
# => {:name=>["can't be blank"]}
 # 
# Invalid gamer level - not valid
carl = Friend.new name: "Carl", gamer_level: 11
# => #<Friend name="Carl" balance_owed=0.0 gamer_level=11>  
carl.valid?
# => false
carl.errors.to_hash
# => {:gamer_level=>["is not included in the list"]}
 
# Invalid zip code - not valid
melanie = Friend.new name: "Melanie", zip_code: '123'
# => #<Friend name="Melanie" balance_owed=0.0 gamer_level=1 zip_code="123">
melanie.valid?
# => false
melanie.errors.to_hash
# => {:zip_code=>["is invalid"]}  
``` 

### `FieldStruct::Mutable`
 
This class has all the same attribute options as `FieldStruct::Value` 
but it allows to instantiate invalid objects and modify the attributes after creation.

```ruby
class User < FieldStruct.mutable
  required :username, :string
  required :password, :string
  required :team, :string, enum: %w{ A B C }
  optional :last_login_at, :time
end

# A first attempt 
john = User.new username: 'john@company.com'
# => #<User username="john@company.com">

# Is it valid? What errors do we have? 
[john.valid?, john.errors.to_hash]
# => => [false, {:password=>["can't be blank"], :team=>["can't be blank", "is not included in the list"]}]

# Let's fix the first error: missing password 
john.password = 'some1234'
# => "some1234"

# Is it valid now? What errors do we still have? 
[john.valid?, john.errors.to_hash]
# => [false, {:team=>["can't be blank", "is not included in the list"]}]

# Let's fix the team
john.team = 'X'
# => "X"

# Are we valid now? Do we still have errors?
[john.valid?, john.errors.to_hash]
# => [false, {:team=>["is not included in the list"]}]

# Let's fix the team for real now
john.team = 'B'
# => "B"

# Are we finally valid now? Do we still have errors?
[john.valid?, john.errors.to_hash]
# => [true, {}]

# The final, valid product
john
# => #<User username="john@company.com" password="some1234" team="B"> 
``` 

### FieldStructs as Class Parents

You can user FieldStruct as parent classes:

```ruby
class Person < FieldStruct.mutable
  required :first_name, :string
  required :last_name, :string
end

class Employee < Person
  required :title, :string
end

class Developer < Employee
  required :language, :string, enum: %w[Ruby Javascript Elixir]
end

person = Person.new first_name: 'John', last_name: 'Doe'
# => #<Person first_name="John" last_name="Doe">
 
employee = Employee.new first_name: 'John', last_name: 'Doe', title: 'Secretary'
# => #<Employee first_name="John" last_name="Doe" title="Secretary">

developer = Developer.new first_name: 'John', last_name: 'Doe', title: 'Developer', language: 'Ruby'
# #<Developer first_name="John" last_name="Doe" title="Developer" language="Ruby">
```

### FieldStructs as Types

You can use your FieldStruct as a nested type definition:

```ruby
class Employee < FieldStruct.mutable
  required :first_name, :string
  required :last_name, :string
  required :title, :string
end

class Team < FieldStruct.mutable
  required :name, :string
  optional :manager, Employee
end

manager = Employee.new first_name: 'Some', last_name: 'Leader', title: 'Manager'
# => #<Employee first_name="Some" last_name="Leader" title="Manager">

team = Team.new name: 'Great Team', manager: manager 
# => #<Team name="Great Team" manager=#<Employee first_name="Some" last_name="Leader" title="Manager">>

# Or use just hashes to build the whole thing:
team = Team.new name: 'Great Team', manager: { first_name: 'Some', last_name: 'Leader', title: 'Manager' }
# => #<Team name="Great Team" manager=#<Employee first_name="Some" last_name="Leader" title="Manager">>
```

### Array Type

You can have attributes that are collections of a single type:

```ruby
class Employee < FieldStruct.mutable
  required :first_name, :string
  required :last_name, :string
  optional :title, :string
end

class Team < FieldStruct.mutable
  required :name, :string
  optional :manager, Employee
  required :members, :array, of: Employee
end

team = Team.new name: 'Great Team', 
  manager: { first_name: 'Some', last_name: 'Leader' },
  members: [
    { first_name: 'Some', last_name: 'Employee' }, 
    { first_name: 'Another', last_name: 'Employee' }
  ]  
# => #<Team name="Great Team" manager=#<Employee first_name="Some" last_name="Leader"> members=[#<Employee first_name="Some" last_name="Employee">, #<Employee first_name="Another" last_name="Employee">]> 
```

### JSON Conversion

You can create structs from JSON and convert them back to JSON. 

```ruby
class Employee < FieldStruct.mutable
  required :first_name, :string
  required :last_name, :string
  optional :title, :string
end

class Team < FieldStruct.mutable
  required :name, :string
  optional :manager, Employee
  required :members, :array, of: Employee
end

class Company < FieldStruct.mutable
  required :legal_name, :string
  optional :development_team, Team
  optional :marketing_team, Team
end

json = %|
{
  "legal_name": "My Company",
  "development_team": {
    "name": "Dev Team",
    "manager": {
      "first_name": "Some",
      "last_name": "Dev",
      "title": "Dev Leader"
    },
    "members": [
      {
        "first_name": "Other",
        "last_name": "Dev",
        "title": "Dev"
      }
    ]
  },
  "marketing_team": {
    "name": "Marketing Team",
    "manager": {
      "first_name": "Some",
      "last_name": "Mark",
      "title": "Mark Leader"
    },
    "members": [
      {
        "first_name": "Another",
        "last_name": "Dev",
        "title": "Dev"
      }
    ]
  }
}
|

company = Company.from_json json
# => #<Company legal_name="My Company" development_team=#<Team name="Dev Team" manager=#<Employee first_name="Some" last_name="Dev" title="Dev Leader"> members=[#<Employee first_name="Other" last_name="Dev" title="Dev">]> marketing_team=#<Team name="Marketing Team" manager=#<Employee first_name="Some" last_name="Mark" title="Mark Leader"> members=[#<Employee first_name="Another" last_name="Dev" title="Dev">]>>

puts company.to_json
# {"legal_name":"My Company","development_team":{"name":"Dev Team","manager":{"first_name":"Some","last_name":"Dev","title":"Dev Leader"},"members":[{"first_name":"Other","last_name":"Dev","title":"Dev"}]},"marketing_team":{"name":"Marketing Team","manager":{"first_name":"Some","last_name":"Mark","title":"Mark Leader"},"members":[{"first_name":"Another","last_name":"Dev","title":"Dev"}]}}
```

### Validations

You can add AR-style validations to your struct. We provide syntactic sugar to make it 
easy to use common validations in the attribute definition.

```ruby
# We have syntactic sugar to turn this definition: 
class Employee < FieldStruct.mutable
  attribute :full_name, :string
  attribute :email, :string
  attribute :team, :string
  
  validates_presence_of :full_name
  validates_format_of :email, allow_nil: true, with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates_inclusion_of :team, allow_nil: true, in: %w{ A B C }  
end

# Into this definition:
class Employee < FieldStruct.mutable
  required :full_name, :string
  optional :email, :string, format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i 
  optional :team, :string, enum: %w{ A B C }
end

# But you can also add more validations too:
class Employee < FieldStruct.mutable
  validates_length_of :email, allow_nil: true, within: 12...120

  validates_each :full_name do |model, attr, value|
    model.errors.add(attr, 'must start with upper case') if value =~ /\A[a-z]/
  end

  validate :check_company_email
  def check_company_email
    return if email.nil?
    errors.add(:email, "has to be a company email") unless email.end_with?("@company.com")
  end
end

bad_employee = Employee.new full_name: 'some name', email: 'bad@xyz', team: 'D'
# => #<Employee full_name="some name" email="bad@xyz" team="D">
bad_employee.errors.to_hash
# => {
#   :email=>["is invalid", "is too short (minimum is 12 characters)", "has to be a company email"], 
#   :team=>["is not included in the list"], 
#   :full_name=>["must start with upper case"]
# } 
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
