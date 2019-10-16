# frozen_string_literal: true

require 'spec_helper'

module FieldStruct
  module Examples
    class UserStrictValue < FieldStruct.strict
      required :username, :string, :strict, format: /^[a-z]/i
      optional :password, :string, :strict
      required :age, :integer, :coercible
      required :owed, :float, :coercible
      required :source, :string, :coercible, enum: %w[A B C]
      required :level, :integer, default: -> { 2 }
      optional :at, :time
      optional :active, :boolean, :coercible, default: false
    end
    class Person < FieldStruct.strict
      required :first_name, :string
      required :last_name, :string
    end
    class Employee < Person
      optional :title, :string
    end
    class Developer < Person
      optional :language, :string
    end
    class Owner < Employee
      optional :percentage, :float
    end
  end
end

RSpec.describe FieldStruct::Examples::UserStrictValue do
  let(:str) { "#<#{described_class.name} #{fields_str}>" }

  let(:username) { 'johnny' }
  let(:password) { 'p0ssw3rd' }
  let(:age) { 3 }
  let(:owed) { 20.75 }
  let(:source) { 'A' }
  let(:level) { 3 }
  let(:at) { nil }
  let(:active) { false }
  let(:params) do
    {
      username: username,
      password: password,
      age: age,
      owed: owed,
      source: source,
      level: level,
      at: at,
      active: active
    }
  end
  subject { described_class.new params }

  context 'class' do
    let(:attr_names) { %i[username password age owed source level at active] }
    it('attribute_names') { expect(described_class.attribute_names).to eq attr_names }
    context 'attributes' do
      context 'username' do
        subject { described_class.attributes[:username] }
        let(:str) do
          '#<FieldStruct::Attribute name=:username type="string" ' \
            'options={:required=>true, :coercible=>false, :format=>/^[a-z]/i}>'
        end
        it { expect(subject.name).to eq :username }
        it { expect(subject.type).to be_a FieldStruct::Types::String }
        it { expect(subject.required?).to eq true }
        it { expect(subject.coercible?).to eq false }
        it { expect(subject.default?).to eq false }
        it { expect(subject.to_s).to eq str }
      end
      context 'password' do
        subject { described_class.attributes[:password] }
        let(:str) do
          '#<FieldStruct::Attribute name=:password type="string" options={:required=>false, :coercible=>false}>'
        end
        it { expect(subject.name).to eq :password }
        it { expect(subject.type).to be_a FieldStruct::Types::String }
        it { expect(subject.required?).to eq false }
        it { expect(subject.coercible?).to eq false }
        it { expect(subject.default?).to eq false }
        it { expect(subject.to_s).to eq str }
      end
      context 'age' do
        subject { described_class.attributes[:age] }
        let(:str) { '#<FieldStruct::Attribute name=:age type="integer" options={:required=>true, :coercible=>true}>' }
        it { expect(subject.name).to eq :age }
        it { expect(subject.type).to be_a FieldStruct::Types::Integer }
        it { expect(subject.required?).to eq true }
        it { expect(subject.coercible?).to eq true }
        it { expect(subject.default?).to eq false }
        it { expect(subject.to_s).to eq str }
      end
      context 'owed' do
        subject { described_class.attributes[:owed] }
        let(:str) { '#<FieldStruct::Attribute name=:owed type="float" options={:required=>true, :coercible=>true}>' }
        it { expect(subject.name).to eq :owed }
        it { expect(subject.type).to be_a FieldStruct::Types::Float }
        it { expect(subject.required?).to eq true }
        it { expect(subject.coercible?).to eq true }
        it { expect(subject.default?).to eq false }
        it { expect(subject.to_s).to eq str }
      end
      context 'source' do
        subject { described_class.attributes[:source] }
        let(:str) do
          '#<FieldStruct::Attribute name=:source type="string" ' \
            'options={:required=>true, :coercible=>true, :enum=>["A", "B", "C"]}>'
        end
        it { expect(subject.name).to eq :source }
        it { expect(subject.type).to be_a FieldStruct::Types::String }
        it { expect(subject.required?).to eq true }
        it { expect(subject.coercible?).to eq true }
        it { expect(subject.default?).to eq false }
        it { expect(subject.to_s).to eq str }
      end
      context 'level' do
        subject { described_class.attributes[:level] }
        it { expect(subject.name).to eq :level }
        it { expect(subject.type).to be_a FieldStruct::Types::Integer }
        it { expect(subject.required?).to eq true }
        it { expect(subject.coercible?).to eq false }
        it { expect(subject.default?).to eq true }
      end
      context 'at' do
        subject { described_class.attributes[:at] }
        let(:str) { '#<FieldStruct::Attribute name=:at type="time" options={:required=>false, :coercible=>false}>' }
        it { expect(subject.name).to eq :at }
        it { expect(subject.type).to be_a FieldStruct::Types::Time }
        it { expect(subject.required?).to eq false }
        it { expect(subject.coercible?).to eq false }
        it { expect(subject.default?).to eq false }
        it { expect(subject.to_s).to eq str }
      end
      context 'active' do
        subject { described_class.attributes[:active] }
        let(:str) do
          '#<FieldStruct::Attribute name=:active type="boolean" ' \
            'options={:required=>false, :coercible=>true, :default=>false}>'
        end
        it { expect(subject.name).to eq :active }
        it { expect(subject.type).to be_a FieldStruct::Types::Boolean }
        it { expect(subject.required?).to eq false }
        it { expect(subject.coercible?).to eq true }
        it { expect(subject.default?).to eq true }
        it { expect(subject.to_s).to eq str }
      end
    end
  end

  context 'instance' do
    context 'basic' do
      shared_examples 'a valid field struct' do
        let(:fields_str) do
          'username="johnny" password="p0ssw3rd" age=3 owed=20.75 source="A" level=3 at=nil active=false'
        end
        let(:exp_hsh) do
          { age: 3, at: nil, level: 3, owed: 20.75, password: 'p0ssw3rd', source: 'A', username: 'johnny',
            active: false }
        end
        let(:exp_query) { 'active=false&age=3&at=&level=3&owed=20.75&password=p0ssw3rd&source=A&username=johnny' }
        let(:exp_json) do
          '{"username":"johnny","password":"p0ssw3rd","age":3,"owed":20.75,"source":"A","level":3,"at":null,' \
            '"active":false}'
        end
        let(:values) { [username, password, age, owed, source, level, at, active] }
        it('to_s      ') { expect(subject.to_s).to eq str }
        it('inspect   ') { expect(subject.inspect).to eq str }
        it('username  ') { expect(subject.username).to eq username }
        it('password  ') { expect(subject.password).to eq password }
        it('age       ') { expect(subject.age).to eq age }
        it('owed      ') { expect(subject.owed).to eq owed }
        it('source    ') { expect(subject.source).to eq source }
        it('level     ') { expect(subject.level).to eq level }
        it('at        ') { expect(subject.at).to eq at }
        it('values    ') { expect(subject.values).to eq values }
        it('to_hash   ') { expect(subject.to_hash).to eq(exp_hsh) }
        it('to_query  ') { expect(subject.to_query).to eq(exp_query) }
        it('to_param  ') { expect(subject.to_param).to eq(exp_query) }
        it('to_json   ') { expect(subject.to_json).to eq(exp_json) }
      end
      context 'instantiate by hash' do
        it_behaves_like 'a valid field struct'
      end
      context 'instantiate by args' do
        subject { described_class.new username, password, age, owed, source, level, at, active }
        it_behaves_like 'a valid field struct'
      end
      context 'instantiate by args and hash' do
        subject do
          described_class.new username, password, age, owed, source: source, level: level, at: at, active: active
        end
        it_behaves_like 'a valid field struct'
      end
    end

    context 'with' do
      let(:error_class) { FieldStruct::BuildError }
      context 'username' do
        context 'missing' do
          let(:params) { { password: password, age: age, owed: owed, source: source } }
          it 'throws an exception' do
            expect { subject }.to raise_error error_class, ':username is required'
          end
        end
        context 'empty' do
          let(:username) { '' }
          it 'throws an exception' do
            expect { subject }.to raise_error error_class, ':username is required'
          end
        end
        context 'nil' do
          let(:username) { nil }
          it 'throws an exception' do
            expect { subject }.to raise_error error_class, ':username is required'
          end
        end
        context 'wrong format' do
          let(:username) { '123' }
          it 'throws an exception' do
            expect { subject }.to raise_error error_class, ':username is not in a valid format'
          end
        end
      end
      context 'password' do
        context 'missing' do
          let(:params) { { username: username, age: age, owed: owed, source: source } }
          it('is ok') { expect(subject.password).to be_nil }
        end
        context 'empty' do
          let(:password) { '' }
          it('is ok') { expect(subject.password).to eq '' }
        end
        context 'nil' do
          let(:password) { nil }
          it('is ok') { expect(subject.password).to be_nil }
        end
      end
      context 'age' do
        context 'missing' do
          let(:params) { { username: username, password: password, owed: owed, source: source } }
          it 'throws an exception' do
            expect { subject }.to raise_error error_class, ':age is required'
          end
        end
        context 'empty' do
          let(:age) { '' }
          it 'throws an exception' do
            expect { subject }.to raise_error error_class, ':age is required'
          end
        end
        context 'nil' do
          let(:age) { nil }
          it 'throws an exception' do
            expect { subject }.to raise_error error_class, ':age is required'
          end
        end
        context 'string' do
          let(:age) { '35' }
          it('is ok') { expect(subject.age).to eq 35 }
        end
        context 'float' do
          let(:age) { 24.32 }
          it('is ok') { expect(subject.age).to eq 24 }
        end
      end
      context 'owed' do
        context 'missing' do
          let(:params) { { username: username, password: password, age: age, source: source } }
          it 'throws an exception' do
            expect { subject }.to raise_error error_class, ':owed is required'
          end
        end
        context 'empty' do
          let(:owed) { '' }
          it 'throws an exception' do
            expect { subject }.to raise_error error_class, ':owed is required'
          end
        end
        context 'nil' do
          let(:owed) { nil }
          it 'throws an exception' do
            expect { subject }.to raise_error error_class, ':owed is required'
          end
        end
        context 'invalid' do
          let(:owed) { '$3.o1' }
          it 'throws an exception' do
            expect { subject }.to raise_error error_class, ':owed is required'
          end
        end
        context '0.0' do
          context 'as string' do
            let(:owed) { '0.0' }
            let(:fields_str) do
              'username="johnny" password="p0ssw3rd" age=3 owed=0.0 source="A" level=3 at=nil active=false'
            end
            it('to_s      ') { expect(subject.to_s).to eq str }
            it('owed    ') { expect(subject.owed).to eq owed.to_f }
          end
          context 'as float' do
            let(:owed) { 0.0 }
            let(:fields_str) do
              'username="johnny" password="p0ssw3rd" age=3 owed=0.0 source="A" level=3 at=nil active=false'
            end
            it('to_s      ') { expect(subject.to_s).to eq str }
            it('owed    ') { expect(subject.owed).to eq owed.to_f }
          end
          context 'as integer' do
            let(:owed) { 0 }
            let(:fields_str) do
              'username="johnny" password="p0ssw3rd" age=3 owed=0.0 source="A" level=3 at=nil active=false'
            end
            it('to_s      ') { expect(subject.to_s).to eq str }
            it('owed    ') { expect(subject.owed).to eq owed.to_f }
          end
          context 'as decimal' do
            let(:owed) { BigDecimal '0' }
            let(:fields_str) do
              'username="johnny" password="p0ssw3rd" age=3 owed=0.0 source="A" level=3 at=nil active=false'
            end
            it('to_s      ') { expect(subject.to_s).to eq str }
            it('owed    ') { expect(subject.owed).to eq owed.to_f }
          end
        end
        context '12.34' do
          context 'as string' do
            let(:owed) { '12.34' }
            let(:fields_str) do
              'username="johnny" password="p0ssw3rd" age=3 owed=12.34 source="A" level=3 at=nil active=false'
            end
            it('to_s      ') { expect(subject.to_s).to eq str }
            it('owed    ') { expect(subject.owed).to eq owed.to_f }
          end
          context 'as float' do
            let(:owed) { 12.34 }
            let(:fields_str) do
              'username="johnny" password="p0ssw3rd" age=3 owed=12.34 source="A" level=3 at=nil active=false'
            end
            it('to_s      ') { expect(subject.to_s).to eq str }
            it('owed    ') { expect(subject.owed).to eq owed.to_f }
          end
          context 'as decimal' do
            let(:owed) { BigDecimal '12.34' }
            let(:fields_str) do
              'username="johnny" password="p0ssw3rd" age=3 owed=12.34 source="A" level=3 at=nil active=false'
            end
            it('to_s      ') { expect(subject.to_s).to eq str }
            it('owed    ') { expect(subject.owed).to eq owed.to_f }
          end
        end
        context '-12.34' do
          context 'as string' do
            let(:owed) { '-12.34' }
            let(:fields_str) do
              'username="johnny" password="p0ssw3rd" age=3 owed=-12.34 source="A" level=3 at=nil active=false'
            end
            it('to_s      ') { expect(subject.to_s).to eq str }
            it('owed    ') { expect(subject.owed).to eq owed.to_f }
          end
          context 'as float' do
            let(:owed) { -12.34 }
            let(:fields_str) do
              'username="johnny" password="p0ssw3rd" age=3 owed=-12.34 source="A" level=3 at=nil active=false'
            end
            it('to_s      ') { expect(subject.to_s).to eq str }
            it('owed    ') { expect(subject.owed).to eq owed.to_f }
          end
          context 'as decimal' do
            let(:owed) { BigDecimal '-12.34' }
            let(:fields_str) do
              'username="johnny" password="p0ssw3rd" age=3 owed=-12.34 source="A" level=3 at=nil active=false'
            end
            it('to_s      ') { expect(subject.to_s).to eq str }
            it('owed    ') { expect(subject.owed).to eq owed.to_f }
          end
        end
        context '$12,345.67' do
          context 'as string' do
            let(:owed) { '$12,345.67' }
            let(:fields_str) do
              'username="johnny" password="p0ssw3rd" age=3 owed=12345.67 source="A" level=3 at=nil active=false'
            end
            it('to_s      ') { expect(subject.to_s).to eq str }
            it('owed    ') { expect(subject.owed).to eq owed.gsub(/\$|\,/, '').to_f }
          end
        end
        context '$-12,345.67' do
          context 'as string' do
            let(:owed) { '$-12,345.67' }
            let(:fields_str) do
              'username="johnny" password="p0ssw3rd" age=3 owed=-12345.67 source="A" level=3 at=nil active=false'
            end
            it('to_s      ') { expect(subject.to_s).to eq str }
            it('owed    ') { expect(subject.owed).to eq owed.gsub(/\$|\,/, '').to_f }
          end
        end
      end
      context 'source' do
        context 'missing' do
          let(:params) { { username: username, password: password, age: age, owed: owed } }
          it 'throws an exception' do
            expect { subject }.to raise_error error_class, ':source is required'
          end
        end
        context 'empty' do
          let(:source) { '' }
          it 'throws an exception' do
            expect { subject }.to raise_error error_class, ':source is required'
          end
        end
        context 'nil' do
          let(:source) { nil }
          it 'throws an exception' do
            expect { subject }.to raise_error error_class, ':source is required'
          end
        end
        context 'unknown' do
          let(:source) { 'unknown' }
          it 'throws an exception' do
            expect { subject }.to raise_error error_class, ':source is not included in list'
          end
        end
        context 'wrong case' do
          let(:source) { 'a' }
          it 'throws an exception' do
            expect { subject }.to raise_error error_class, ':source is not included in list'
          end
        end
      end
      context 'level' do
        context 'missing' do
          let(:params) { { username: username, password: password, age: age, owed: owed, source: source } }
          it('uses the default') { expect(subject.level).to eq 2 }
        end
        context 'empty' do
          let(:level) { '' }
          it 'throws an exception' do
            expect { subject }.to raise_error error_class, ':level is required'
          end
        end
        context 'nil' do
          let(:level) { nil }
          it 'throws an exception' do
            expect { subject }.to raise_error error_class, ':level is required'
          end
        end
      end
      context 'no params' do
        subject { described_class.new }
        it 'does raise a build error' do
          expect { subject }.to raise_error error_class, ':username is required'
        end
      end
    end

    context 'immutability' do
      let(:error_class) { NoMethodError }
      context 'username' do
        it('responds_to') { expect(subject.respond_to?(:username=)).to eq false }
        it { expect { subject.username = 'other' }.to raise_error(error_class, /undefined method `username='/) }
      end
      context 'password' do
        it('responds_to') { expect(subject.respond_to?(:password=)).to eq false }
        it { expect { subject.password = 'other' }.to raise_error(error_class, /undefined method `password='/) }
      end
      context 'age' do
        it('responds_to') { expect(subject.respond_to?(:age=)).to eq false }
        it { expect { subject.age = 2 }.to raise_error(error_class, /undefined method `age='/) }
      end
      context 'owed' do
        it('responds_to') { expect(subject.respond_to?(:owed=)).to eq false }
        it { expect { subject.owed = 'other' }.to raise_error(error_class, /undefined method `owed='/) }
      end
      context 'source' do
        it('responds_to') { expect(subject.respond_to?(:source=)).to eq false }
        it { expect { subject.source = 'other' }.to raise_error(error_class, /undefined method `source='/) }
      end
    end
  end
end

RSpec.describe FieldStruct::Examples::Person do
  let(:str) { "#<#{described_class.name} #{fields_str}>" }

  let(:first_name) { 'John' }
  let(:last_name) { 'Smith' }
  let(:params) do
    {
      first_name: first_name,
      last_name: last_name
    }
  end
  subject { described_class.new params }

  context 'class' do
    let(:attr_names) { %i[first_name last_name] }
    it('attribute_names') { expect(described_class.attribute_names).to eq attr_names }
  end

  context 'instance' do
    context 'basic' do
      shared_examples 'a valid field struct' do
        let(:fields_str) do
          'first_name="John" last_name="Smith"'
        end
        let(:exp_hsh) do
          { first_name: 'John', last_name: 'Smith' }
        end
        let(:exp_query) { 'first_name=John&last_name=Smith' }
        let(:exp_json) do
          '{"first_name":"John","last_name":"Smith"}'
        end
        let(:values) { [first_name, last_name] }
        it('to_s      ') { expect(subject.to_s).to eq str }
        it('inspect   ') { expect(subject.inspect).to eq str }
        it('first_name') { expect(subject.first_name).to eq first_name }
        it('last_name ') { expect(subject.last_name).to eq last_name }
        it('values    ') { expect(subject.values).to eq values }
        it('to_hash   ') { expect(subject.to_hash).to eq(exp_hsh) }
        it('to_query  ') { expect(subject.to_query).to eq(exp_query) }
        it('to_param  ') { expect(subject.to_param).to eq(exp_query) }
        it('to_json   ') { expect(subject.to_json).to eq(exp_json) }
      end
      context 'instantiate by hash' do
        it_behaves_like 'a valid field struct'
      end
      context 'instantiate by args' do
        subject { described_class.new first_name, last_name }
        it_behaves_like 'a valid field struct'
      end
      context 'instantiate by args and hash' do
        subject do
          described_class.new first_name, last_name: last_name
        end
        it_behaves_like 'a valid field struct'
      end
    end
  end
end

RSpec.describe FieldStruct::Examples::Employee do
  let(:str) { "#<#{described_class.name} #{fields_str}>" }

  let(:first_name) { 'John' }
  let(:last_name) { 'Smith' }
  let(:title) { 'Admin' }
  let(:params) do
    {
      first_name: first_name,
      last_name: last_name,
      title: title
    }
  end
  subject { described_class.new params }

  context 'class' do
    let(:attr_names) { %i[first_name last_name title] }
    it('attribute_names') { expect(described_class.attribute_names).to eq attr_names }
  end

  context 'instance' do
    context 'basic' do
      shared_examples 'a valid field struct' do
        let(:fields_str) do
          'first_name="John" last_name="Smith" title="Admin"'
        end
        let(:exp_hsh) do
          { first_name: 'John', last_name: 'Smith', title: 'Admin' }
        end
        let(:exp_query) { 'first_name=John&last_name=Smith&title=Admin' }
        let(:exp_json) do
          '{"first_name":"John","last_name":"Smith","title":"Admin"}'
        end
        let(:values) { [first_name, last_name, title] }
        it('to_s      ') { expect(subject.to_s).to eq str }
        it('inspect   ') { expect(subject.inspect).to eq str }
        it('first_name') { expect(subject.first_name).to eq first_name }
        it('last_name ') { expect(subject.last_name).to eq last_name }
        it('title     ') { expect(subject.title).to eq title }
        it('values    ') { expect(subject.values).to eq values }
        it('to_hash   ') { expect(subject.to_hash).to eq(exp_hsh) }
        it('to_query  ') { expect(subject.to_query).to eq(exp_query) }
        it('to_param  ') { expect(subject.to_param).to eq(exp_query) }
        it('to_json   ') { expect(subject.to_json).to eq(exp_json) }
      end
      context 'instantiate by hash' do
        it_behaves_like 'a valid field struct'
      end
      context 'instantiate by args' do
        subject { described_class.new first_name, last_name, title }
        it_behaves_like 'a valid field struct'
      end
      context 'instantiate by args and hash' do
        subject do
          described_class.new first_name, last_name, title: title
        end
        it_behaves_like 'a valid field struct'
      end
    end
  end
end

RSpec.describe FieldStruct::Examples::Developer do
  let(:str) { "#<#{described_class.name} #{fields_str}>" }

  let(:first_name) { 'John' }
  let(:last_name) { 'Smith' }
  let(:language) { 'Ruby' }
  let(:params) do
    {
      first_name: first_name,
      last_name: last_name,
      language: language
    }
  end
  subject { described_class.new params }

  context 'class' do
    let(:attr_names) { %i[first_name last_name language] }
    it('attribute_names') { expect(described_class.attribute_names).to eq attr_names }
  end

  context 'instance' do
    context 'basic' do
      shared_examples 'a valid field struct' do
        let(:fields_str) do
          'first_name="John" last_name="Smith" language="Ruby"'
        end
        let(:exp_hsh) do
          { first_name: 'John', last_name: 'Smith', language: 'Ruby' }
        end
        let(:exp_query) { 'first_name=John&language=Ruby&last_name=Smith' }
        let(:exp_json) do
          '{"first_name":"John","last_name":"Smith","language":"Ruby"}'
        end
        let(:values) { [first_name, last_name, language] }
        it('to_s      ') { expect(subject.to_s).to eq str }
        it('inspect   ') { expect(subject.inspect).to eq str }
        it('first_name') { expect(subject.first_name).to eq first_name }
        it('last_name ') { expect(subject.last_name).to eq last_name }
        it('language  ') { expect(subject.language).to eq language }
        it('values    ') { expect(subject.values).to eq values }
        it('to_hash   ') { expect(subject.to_hash).to eq(exp_hsh) }
        it('to_query  ') { expect(subject.to_query).to eq(exp_query) }
        it('to_param  ') { expect(subject.to_param).to eq(exp_query) }
        it('to_json   ') { expect(subject.to_json).to eq(exp_json) }
      end
      context 'instantiate by hash' do
        it_behaves_like 'a valid field struct'
      end
      context 'instantiate by args' do
        subject { described_class.new first_name, last_name, language }
        it_behaves_like 'a valid field struct'
      end
      context 'instantiate by args and hash' do
        subject do
          described_class.new first_name, last_name, language: language
        end
        it_behaves_like 'a valid field struct'
      end
    end
  end
end

RSpec.describe FieldStruct::Examples::Owner do
  let(:str) { "#<#{described_class.name} #{fields_str}>" }

  let(:first_name) { 'John' }
  let(:last_name) { 'Smith' }
  let(:title) { 'Owner' }
  let(:percentage) { 25.0 }
  let(:params) do
    {
      first_name: first_name,
      last_name: last_name,
      title: title,
      percentage: percentage
    }
  end
  subject { described_class.new params }

  context 'class' do
    let(:attr_names) { %i[first_name last_name title percentage] }
    it('attribute_names') { expect(described_class.attribute_names).to eq attr_names }
  end

  context 'instance' do
    context 'basic' do
      shared_examples 'a valid field struct' do
        let(:fields_str) do
          'first_name="John" last_name="Smith" title="Owner" percentage=25.0'
        end
        let(:exp_hsh) do
          { first_name: 'John', last_name: 'Smith', title: 'Owner', percentage: 25.0 }
        end
        let(:exp_query) { 'first_name=John&last_name=Smith&percentage=25.0&title=Owner' }
        let(:exp_json) do
          '{"first_name":"John","last_name":"Smith","title":"Owner","percentage":25.0}'
        end
        let(:values) { [first_name, last_name, title, percentage] }
        it('to_s      ') { expect(subject.to_s).to eq str }
        it('inspect   ') { expect(subject.inspect).to eq str }
        it('first_name') { expect(subject.first_name).to eq first_name }
        it('last_name ') { expect(subject.last_name).to eq last_name }
        it('percentage') { expect(subject.percentage).to eq percentage }
        it('values    ') { expect(subject.values).to eq values }
        it('to_hash   ') { expect(subject.to_hash).to eq(exp_hsh) }
        it('to_query  ') { expect(subject.to_query).to eq(exp_query) }
        it('to_param  ') { expect(subject.to_param).to eq(exp_query) }
        it('to_json   ') { expect(subject.to_json).to eq(exp_json) }
      end
      context 'instantiate by hash' do
        it_behaves_like 'a valid field struct'
      end
      context 'instantiate by args' do
        subject { described_class.new first_name, last_name, title, percentage }
        it_behaves_like 'a valid field struct'
      end
      context 'instantiate by args and hash' do
        subject do
          described_class.new first_name, last_name, title: title, percentage: percentage
        end
        it_behaves_like 'a valid field struct'
      end
    end
  end
end
