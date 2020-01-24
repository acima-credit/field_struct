# frozen_string_literal: true

require 'spec_helper'

module FieldStruct
  module FlexibleExamples
    class User < FieldStruct.flexible
      required :username, :string, format: /\A[a-z]/i, description: 'login'
      optional :password, :string
      required :age, :integer
      required :owed, :float, description: 'amount owed to the company'
      required :source, :string, enum: %w[A B C]
      required :level, :integer, default: -> { 2 }
      optional :at, :time
      optional :active, :boolean, default: false
    end

    class Person < FieldStruct.flexible
      required :first_name, :string, length: 3..20
      required :last_name, :string

      def full_name
        [first_name, last_name].select(&:present?).join(' ')
      end
    end

    class Employee < Person
      extras :add
      optional :title, :string
    end

    class Developer < Employee
      required :language, :string
    end

    class Team < FieldStruct.flexible
      extras :ignore
      required :name, :string
      required :leader, 'FieldStruct::FlexibleExamples::Employee'
      required :members, :array, of: Employee, description: 'Team members'
    end

    class Company < FieldStruct.flexible
      required :legal_name, :string
      optional :development_team, Team
      optional :marketing_team, Team
    end
  end
end

RSpec.describe FieldStruct::FlexibleExamples::User do
  describe 'class' do
    it { expect(described_class.model_name).to be_a ActiveModel::Name }
    it { expect(described_class.extras).to eq :raise }
    context '.metadata' do
      subject { described_class.metadata }
      it { expect(subject.name).to eq 'FieldStruct::FlexibleExamples::User' }
      it { expect(subject.schema_name).to eq 'field_struct.flexible_examples.user' }
      it { expect(subject.type).to eq :flexible }
      it { expect(subject.version).to eq '245178bc' }
      it('full hash') do
        expect(subject.to_hash).to eq name: 'FieldStruct::FlexibleExamples::User',
                                      schema_name: 'field_struct.flexible_examples.user',
                                      attributes: {
                                        username: {
                                          type: :string,
                                          required: true,
                                          format: /\A[a-z]/i,
                                          description: 'login'
                                        },
                                        password: { type: :string },
                                        age: { type: :integer, required: true },
                                        owed: {
                                          type: :float,
                                          required: true,
                                          description: 'amount owed to the company'
                                        },
                                        source: { type: :string, required: true, enum: %w[A B C] },
                                        level: { type: :integer, required: true, default: '<proc>' },
                                        at: { type: :time },
                                        active: { type: :boolean, default: false }
                                      },
                                      version: '245178bc'
      end
      it 'filtered hash' do
        options = { attributes: { attribute: { only_keys: %i[type of required default enum] } } }
        expect(subject.to_hash(options)).to eq name: 'FieldStruct::FlexibleExamples::User',
                                               schema_name: 'field_struct.flexible_examples.user',
                                               attributes: {
                                                 username: { type: :string, required: true },
                                                 password: { type: :string },
                                                 age: { type: :integer, required: true },
                                                 owed: { type: :float, required: true },
                                                 source: { type: :string, required: true, enum: %w[A B C] },
                                                 level: { type: :integer, required: true, default: '<proc>' },
                                                 at: { type: :time },
                                                 active: { type: :boolean, default: false }
                                               },
                                               version: '245178bc'
      end
    end
    context '.attribute_types' do
      subject { described_class.attribute_types }
      it { expect(subject).to be_a Hash }
      it { expect(subject.keys).to eq %w[username password age owed source level at active] }
      it { expect(subject['username']).to be_a ActiveModel::Type::String }
      it { expect(subject['password']).to be_a ActiveModel::Type::String }
      it { expect(subject['age']).to be_a ActiveModel::Type::Integer }
      it { expect(subject['owed']).to be_a ActiveModel::Type::Float }
      it { expect(subject['source']).to be_a ActiveModel::Type::String }
      it { expect(subject['level']).to be_a ActiveModel::Type::Integer }
      it { expect(subject['at']).to be_a ActiveModel::Type::Time }
      it { expect(subject['active']).to be_a ActiveModel::Type::Boolean }
    end
  end
  describe 'instance' do
    let(:username) { 'some_user' }
    let(:password) { '123' }
    let(:age) { 25 }
    let(:owed) { 50.0 }
    let(:source) { 'B' }
    let(:level) { 3 }
    let(:at) { Time.parse('2018-03-24') }
    let(:active) { true }
    let(:full_params) do
      basic_hash username: username,
                 password: password,
                 age: age,
                 owed: owed,
                 source: source,
                 level: level,
                 at: at,
                 active: active
    end
    subject { described_class.new params }
    context 'full' do
      let(:params) { full_params }
      context 'attributes' do
        it { expect(subject).to be_valid }
        it { expect(subject.username).to eq 'some_user' }
        it { expect(subject.password).to eq '123' }
        it { expect(subject.age).to eq 25 }
        it { expect(subject.owed).to eq 50.0 }
        it { expect(subject.source).to eq 'B' }
        it { expect(subject.level).to eq 3 }
        it { expect(subject.at).to eq Time.parse('2018-03-24') }
        it { expect(subject.active).to eq true }
        it { expect(subject.extras).to eq({}) }
      end
      context 'immutability' do
        it { expect { subject.username = 'x' }.to raise_error FrozenError, "can't modify frozen Hash" }
        it { expect { subject.password = 'x' }.to raise_error FrozenError, "can't modify frozen Hash" }
        it { expect { subject.age = 'x' }.to raise_error FrozenError, "can't modify frozen Hash" }
        it { expect { subject.owed = 'x' }.to raise_error FrozenError, "can't modify frozen Hash" }
        it { expect { subject.source = 'x' }.to raise_error FrozenError, "can't modify frozen Hash" }
        it { expect { subject.level = 'x' }.to raise_error FrozenError, "can't modify frozen Hash" }
        it { expect { subject.at = 'x' }.to raise_error FrozenError, "can't modify frozen Hash" }
        it { expect { subject.active = 'x' }.to raise_error FrozenError, "can't modify frozen Hash" }
      end
    end
    context 'full + extras' do
      let(:params) { full_params.merge(a: 1, b: [2]) }
      let(:error_class) { FieldStruct::UnknownAttributeError }
      let(:message) { "unknown attribute 'a' for #{described_class}." }
      it { expect { subject }.to raise_error error_class, message }
    end
    context 'partial' do
      let(:params) { full_params.except :source, :level, :at, :active }
      let(:errors) { { source: ["can't be blank"] } }
      let(:messages) { ["Source can't be blank"] }
      it { expect(subject).to_not be_valid }
      it { expect(subject.username).to eq 'some_user' }
      it { expect(subject.password).to eq '123' }
      it { expect(subject.age).to eq 25 }
      it { expect(subject.owed).to eq 50.0 }
      it { expect(subject.source).to eq nil }
      it { expect(subject.level).to eq 2 }
      it { expect(subject.at).to eq nil }
      it { expect(subject.active).to eq false }
      it { expect(subject.errors).to be_a ActiveModel::Errors }
      it { expect(subject.errors.to_hash).to eq errors }
      it { expect(subject.errors.full_messages).to eq messages }
    end
  end
end

RSpec.describe FieldStruct::FlexibleExamples::Person do
  describe 'class' do
    it { expect(described_class.model_name).to be_a ActiveModel::Name }
    it { expect(described_class.extras).to eq :raise }
    context '.metadata' do
      subject { described_class.metadata }
      it { expect(subject.name).to eq 'FieldStruct::FlexibleExamples::Person' }
      it { expect(subject.schema_name).to eq 'field_struct.flexible_examples.person' }
      it { expect(subject.type).to eq :flexible }
      it { expect(subject.version).to eq '75b71433' }
      it do
        expect(subject.to_hash).to eq name: 'FieldStruct::FlexibleExamples::Person',
                                      schema_name: 'field_struct.flexible_examples.person',
                                      attributes: {
                                        first_name: { type: :string, required: true, min_length: 3, max_length: 20 },
                                        last_name: { type: :string, required: true }
                                      },
                                      version: '75b71433'
      end
    end
    context '.attribute_types' do
      subject { described_class.attribute_types }
      it { expect(subject).to be_a Hash }
      it { expect(subject.keys).to eq %w[first_name last_name] }
      it { expect(subject['first_name']).to be_a ActiveModel::Type::String }
      it { expect(subject['last_name']).to be_a ActiveModel::Type::String }
    end
  end
  describe 'instance' do
    let(:full_params) do
      basic_hash first_name: 'Some',
                 last_name: 'Person'
    end
    subject { described_class.new params }
    context 'full' do
      let(:params) { full_params }
      it { expect(subject).to be_valid }
      it { expect(subject.first_name).to eq 'Some' }
      it { expect(subject.last_name).to eq 'Person' }
      it { expect(subject.full_name).to eq 'Some Person' }
      it { expect(subject.extras).to eq({}) }
    end
    context 'full + extras' do
      let(:params) { full_params.merge(a: 1, b: [2]) }
      let(:error_class) { FieldStruct::UnknownAttributeError }
      let(:message) { "unknown attribute 'a' for #{described_class}." }
      it { expect { subject }.to raise_error error_class, message }
    end
    context 'partial' do
      let(:params) { full_params.except :last_name }
      let(:errors) { { last_name: ["can't be blank"] } }
      let(:messages) { ["Last name can't be blank"] }
      it { expect(subject).to_not be_valid }
      it { expect(subject.first_name).to eq 'Some' }
      it { expect(subject.last_name).to eq nil }
      it { expect(subject.full_name).to eq 'Some' }
      it { expect(subject.errors).to be_a ActiveModel::Errors }
      it { expect(subject.errors.to_hash).to eq errors }
      it { expect(subject.errors.full_messages).to eq messages }
    end
  end
end

RSpec.describe FieldStruct::FlexibleExamples::Employee do
  describe 'class' do
    it { expect(described_class.model_name).to be_a ActiveModel::Name }
    it { expect(described_class.extras).to eq :add }
    context '.metadata' do
      subject { described_class.metadata }
      it { expect(subject.name).to eq 'FieldStruct::FlexibleExamples::Employee' }
      it { expect(subject.schema_name).to eq 'field_struct.flexible_examples.employee' }
      it { expect(subject.type).to eq :flexible }
      it { expect(subject.version).to eq 'c4c4ab50' }
      it { expect(subject.keys).to eq %i[first_name last_name title] }
      it { expect(subject[:first_name]).to eq type: :string, required: true, min_length: 3, max_length: 20 }
      it { expect(subject[:last_name]).to eq type: :string, required: true }
      it { expect(subject[:title]).to eq type: :string }
    end
    context '.attribute_types' do
      subject { described_class.attribute_types }
      it { expect(subject).to be_a Hash }
      it { expect(subject.keys).to eq %w[first_name last_name title] }
      it { expect(subject['first_name']).to be_a ActiveModel::Type::String }
      it { expect(subject['last_name']).to be_a ActiveModel::Type::String }
      it { expect(subject['title']).to be_a ActiveModel::Type::String }
    end
  end
  describe 'instance' do
    let(:full_params) do
      basic_hash first_name: 'Some',
                 last_name: 'Person',
                 title: 'Leader'
    end
    subject { described_class.new params }
    context 'full' do
      let(:params) { full_params }
      it { expect(subject).to be_valid }
      it { expect(subject.first_name).to eq 'Some' }
      it { expect(subject.last_name).to eq 'Person' }
      it { expect(subject.title).to eq 'Leader' }
      it { expect(subject.full_name).to eq 'Some Person' }
    end
    context 'full + extras' do
      let(:params) { full_params.merge(a: 1, b: [2]) }
      it { expect(subject).to be_valid }
      it { expect(subject.first_name).to eq 'Some' }
      it { expect(subject.last_name).to eq 'Person' }
      it { expect(subject.title).to eq 'Leader' }
      it { expect(subject.full_name).to eq 'Some Person' }
      it { expect(subject.extras).to eq('a' => 1, 'b' => [2]) }
    end
    context 'partial' do
      let(:params) { full_params.except :last_name }
      let(:errors) { { last_name: ["can't be blank"] } }
      let(:messages) { ["Last name can't be blank"] }
      it { expect(subject).to_not be_valid }
      it { expect(subject.first_name).to eq 'Some' }
      it { expect(subject.last_name).to eq nil }
      it { expect(subject.title).to eq 'Leader' }
      it { expect(subject.full_name).to eq 'Some' }
      it { expect(subject.errors).to be_a ActiveModel::Errors }
      it { expect(subject.errors.to_hash).to eq errors }
      it { expect(subject.errors.full_messages).to eq messages }
    end
  end
end

RSpec.describe FieldStruct::FlexibleExamples::Developer do
  describe 'class' do
    it { expect(described_class.model_name).to be_a ActiveModel::Name }
    it { expect(described_class.extras).to eq :add }
    context '.metadata' do
      subject { described_class.metadata }
      it { expect(subject.name).to eq 'FieldStruct::FlexibleExamples::Developer' }
      it { expect(subject.schema_name).to eq 'field_struct.flexible_examples.developer' }
      it { expect(subject.type).to eq :flexible }
      it { expect(subject.version).to eq 'b061a6fa' }
      it { expect(subject.keys).to eq %i[first_name last_name title language] }
      it { expect(subject[:first_name]).to eq type: :string, required: true, min_length: 3, max_length: 20 }
      it { expect(subject[:last_name]).to eq type: :string, required: true }
      it { expect(subject[:title]).to eq type: :string }
      it { expect(subject[:language]).to eq type: :string, required: true }
    end
    context '.attribute_types' do
      subject { described_class.attribute_types }
      it { expect(subject).to be_a Hash }
      it { expect(subject.keys).to eq %w[first_name last_name title language] }
      it { expect(subject['first_name']).to be_a ActiveModel::Type::String }
      it { expect(subject['last_name']).to be_a ActiveModel::Type::String }
      it { expect(subject['title']).to be_a ActiveModel::Type::String }
      it { expect(subject['language']).to be_a ActiveModel::Type::String }
    end
  end
  describe 'instance' do
    let(:full_params) do
      basic_hash first_name: 'Some',
                 last_name: 'Person',
                 title: 'Leader',
                 language: 'Ruby'
    end
    subject { described_class.new params }
    context 'full' do
      let(:params) { full_params }
      it { expect(subject).to be_valid }
      it { expect(subject.first_name).to eq 'Some' }
      it { expect(subject.last_name).to eq 'Person' }
      it { expect(subject.title).to eq 'Leader' }
      it { expect(subject.language).to eq 'Ruby' }
      it { expect(subject.full_name).to eq 'Some Person' }
      it { expect(subject.extras).to eq({}) }
    end
    context 'full + extras' do
      let(:params) { full_params.merge(a: 1, b: [2]) }
      it { expect(subject).to be_valid }
      it { expect(subject.first_name).to eq 'Some' }
      it { expect(subject.last_name).to eq 'Person' }
      it { expect(subject.title).to eq 'Leader' }
      it { expect(subject.full_name).to eq 'Some Person' }
      it { expect(subject.extras).to eq('a' => 1, 'b' => [2]) }
    end
    context 'partial' do
      let(:params) { full_params.except :last_name }
      let(:errors) { { last_name: ["can't be blank"] } }
      let(:messages) { ["Last name can't be blank"] }
      it { expect(subject.first_name).to eq 'Some' }
      it { expect(subject.last_name).to eq nil }
      it { expect(subject.title).to eq 'Leader' }
      it { expect(subject.language).to eq 'Ruby' }
      it { expect(subject.full_name).to eq 'Some' }
      it { expect(subject.errors).to be_a ActiveModel::Errors }
      it { expect(subject.errors.to_hash).to eq errors }
      it { expect(subject.errors.full_messages).to eq messages }
    end
  end
end

RSpec.describe FieldStruct::FlexibleExamples::Team do
  let(:leader_class) { FieldStruct::FlexibleExamples::Employee }
  let(:member_class) { leader_class }
  describe 'class' do
    it { expect(described_class.model_name).to be_a ActiveModel::Name }
    it { expect(described_class.extras).to eq :ignore }
    context '.metadata' do
      subject { described_class.metadata }
      it { expect(subject.name).to eq 'FieldStruct::FlexibleExamples::Team' }
      it { expect(subject.schema_name).to eq 'field_struct.flexible_examples.team' }
      it { expect(subject.type).to eq :flexible }
      it { expect(subject.version).to eq '5a034ba' }
      it { expect(subject.keys).to eq %i[name leader members] }
      it { expect(subject[:name]).to eq type: :string, required: true }
      it do
        expect(subject[:leader]).to eq type: FieldStruct::FlexibleExamples::Employee,
                                       version: 'c4c4ab50',
                                       required: true
      end
      it do
        expect(subject[:members]).to eq type: :array,
                                        version: 'c4c4ab50',
                                        required: true,
                                        of: FieldStruct::FlexibleExamples::Employee,
                                        description: 'Team members'
      end
    end
    context '.attribute_types' do
      subject { described_class.attribute_types }
      it { expect(subject).to be_a Hash }
      it { expect(subject.keys).to eq %w[name leader members] }
      it { expect(subject['name']).to be_a ActiveModel::Type::String }
      it { expect(subject['leader']).to eq leader_class }
      it { expect(subject['members']).to be_a FieldStruct::Type::Array }
      it { expect(subject['members'].of).to eq member_class }
    end
  end
  describe 'instance' do
    let(:full_params) do
      basic_hash name: 'My Team',
                 leader: { first_name: 'Some', last_name: 'Person', title: 'Leader' },
                 members: [
                   { first_name: 'Other', last_name: 'Person', title: 'Developer' },
                   { first_name: 'Another', last_name: 'Person', title: 'Developer' }
                 ]
    end
    subject { described_class.new params }
    let(:leader) { leader_class.new full_params[:leader] }
    let(:dev1) { leader_class.new full_params[:members][0] }
    let(:dev2) { leader_class.new full_params[:members][1] }
    context 'full hash only' do
      let(:params) { full_params }
      it { expect(subject).to be_valid }
      it { expect(subject.name).to eq 'My Team' }
      it { expect(subject.leader).to be_a leader_class }
      it { expect(subject.leader.to_hash).to eq params[:leader] }
      it { expect(subject.leader).to eq leader }
      it('members') { expect(subject.members).to eq [dev1, dev2] }
      it { expect(subject.extras).to eq({}) }
    end
    context 'hash with struct' do
      let(:params) { full_params.merge leader: leader }
      it { expect(subject).to be_valid }
      it { expect(subject.name).to eq 'My Team' }
      it { expect(subject.leader).to be_a leader_class }
      it { expect(subject.leader).to eq leader }
      it { expect(subject.members).to eq [dev1, dev2] }
      it { expect(subject.extras).to eq({}) }
      it { expect(subject.extras).to eq({}) }
    end
    context 'full + extras' do
      let(:params) { full_params.merge(a: 1, b: [2]) }
      it { expect(subject).to be_valid }
      it { expect(subject.name).to eq 'My Team' }
      it { expect(subject.leader).to be_a leader_class }
      it { expect(subject.leader.to_hash).to eq params[:leader] }
      it { expect(subject.leader).to eq leader }
      it('members') { expect(subject.members).to eq [dev1, dev2] }
      it { expect(subject.extras).to eq({}) }
    end
    context 'partial' do
      let(:params) { full_params.except :leader }
      let(:errors) { { leader: ["can't be blank"] } }
      let(:messages) { ["Leader can't be blank"] }
      it { expect(subject).to_not be_valid }
      it { expect(subject.name).to eq 'My Team' }
      it { expect(subject.leader).to eq nil }
      it { expect(subject.errors).to be_a ActiveModel::Errors }
      it { expect(subject.errors.to_hash).to eq errors }
      it { expect(subject.errors.full_messages).to eq messages }
    end
  end
end

RSpec.describe FieldStruct::FlexibleExamples::Company do
  describe 'class' do
    it { expect(described_class.model_name).to be_a ActiveModel::Name }
    it { expect(described_class.extras).to eq :raise }
    context '.metadata' do
      subject { described_class.metadata }
      it { expect(subject.name).to eq 'FieldStruct::FlexibleExamples::Company' }
      it { expect(subject.schema_name).to eq 'field_struct.flexible_examples.company' }
      it { expect(subject.type).to eq :flexible }
      it { expect(subject.version).to eq '21b9bca5' }
      it { expect(subject.keys).to eq %i[legal_name development_team marketing_team] }
      it { expect(subject[:legal_name]).to eq type: :string, required: true }
      it { expect(subject[:development_team]).to eq type: FieldStruct::FlexibleExamples::Team, version: '5a034ba' }
      it { expect(subject[:marketing_team]).to eq type: FieldStruct::FlexibleExamples::Team, version: '5a034ba' }
    end
    context '.attribute_types' do
      subject { described_class.attribute_types }
      it { expect(subject).to be_a Hash }
      it { expect(subject.keys).to eq %w[legal_name development_team marketing_team] }
      it { expect(subject['legal_name']).to be_a ActiveModel::Type::String }
      it { expect(subject['development_team']).to eq FieldStruct::FlexibleExamples::Team }
      it { expect(subject['marketing_team']).to eq FieldStruct::FlexibleExamples::Team }
    end
  end
  describe 'instance' do
    let(:full_params) do
      basic_hash legal_name: 'My Company',
                 development_team: {
                   name: 'Dev Team',
                   leader: { first_name: 'Some', last_name: 'Dev', title: 'Dev Leader' },
                   members: [{ first_name: 'Other', last_name: 'Dev', title: 'Dev' }]
                 },
                 marketing_team: {
                   name: 'Marketing Team',
                   leader: { first_name: 'Some', last_name: 'Mark', title: 'Mark Leader' },
                   members: [{ first_name: 'Another', last_name: 'Dev', title: 'Dev' }]
                 }
    end
    subject { described_class.new params }
    let(:leader_class) { FieldStruct::FlexibleExamples::Employee }
    let(:team_class) { FieldStruct::FlexibleExamples::Team }
    let(:dev_team) { team_class.new full_params[:development_team] }
    let(:dev_team_leader) { leader_class.new full_params[:development_team][:leader] }
    let(:mark_team) { team_class.new full_params[:marketing_team] }
    let(:mark_team_leader) { leader_class.new full_params[:marketing_team][:leader] }
    context 'full hash only' do
      let(:params) { full_params }
      it { expect(subject).to be_valid }
      it { expect(subject.errors.to_hash).to eq({}) }
      it { expect(subject.legal_name).to eq 'My Company' }
      it { expect(subject.development_team).to be_a team_class }
      it { expect(subject.development_team).to eq dev_team }
      it { expect(subject.marketing_team).to be_a team_class }
      it { expect(subject.marketing_team).to eq mark_team }
      it { expect(subject.extras).to eq({}) }
      context 'conversion' do
        let(:hsh) do
          basic_hash legal_name: 'My Company',
                     development_team: {
                       name: 'Dev Team',
                       leader: { first_name: 'Some', last_name: 'Dev', title: 'Dev Leader' },
                       members: [{ first_name: 'Other', last_name: 'Dev', title: 'Dev' }]
                     },
                     marketing_team: {
                       name: 'Marketing Team',
                       leader: { first_name: 'Some', last_name: 'Mark', title: 'Mark Leader' },
                       members: [{ first_name: 'Another', last_name: 'Dev', title: 'Dev' }]
                     }
        end
        let(:json) do
          '{"legal_name":"My Company",' \
            '"development_team":{"name":"Dev Team",' \
            '"leader":{"first_name":"Some","last_name":"Dev","title":"Dev Leader"},' \
            '"members":[{"first_name":"Other","last_name":"Dev","title":"Dev"}]},' \
            '"marketing_team":{"name":"Marketing Team",' \
            '"leader":{"first_name":"Some","last_name":"Mark","title":"Mark Leader"},' \
            '"members":[{"first_name":"Another","last_name":"Dev","title":"Dev"}]}}'
        end
        it('to_hash  ') { expect_same_hash hsh, subject.to_hash }
        it('as_json  ') { expect_same_hash hsh, subject.as_json }
        it('to_json  ') { expect(subject.to_json).to eq(json) }
        it('from hash') { expect(subject).to eq(described_class.new(subject.to_hash)) }
        it('from json') { expect(subject).to eq(described_class.from_json(subject.to_json)) }
      end
    end
    context 'hash with struct' do
      let(:params) { full_params.merge development_team: dev_team, marketing_team: mark_team }
      it { expect(subject).to be_valid }
      it { expect(subject.errors.to_hash).to eq({}) }
      it { expect(subject.legal_name).to eq 'My Company' }
      it { expect(subject.development_team).to be_a team_class }
      it { expect(subject.development_team).to eq dev_team }
      it { expect(subject.marketing_team).to be_a team_class }
      it { expect(subject.marketing_team).to eq mark_team }
      it { expect(subject.extras).to eq({}) }
      context 'conversion' do
        let(:hsh) do
          basic_hash legal_name: 'My Company',
                     development_team: {
                       name: 'Dev Team',
                       leader: { first_name: 'Some', last_name: 'Dev', title: 'Dev Leader' },
                       members: [{ first_name: 'Other', last_name: 'Dev', title: 'Dev' }]
                     },
                     marketing_team: {
                       name: 'Marketing Team',
                       leader: { first_name: 'Some', last_name: 'Mark', title: 'Mark Leader' },
                       members: [{ first_name: 'Another', last_name: 'Dev', title: 'Dev' }]
                     }
        end
        let(:json) do
          '{"legal_name":"My Company",' \
            '"development_team":' \
            '{"name":"Dev Team","leader":{"first_name":"Some","last_name":"Dev","title":"Dev Leader"},' \
            '"members":[{"first_name":"Other","last_name":"Dev","title":"Dev"}]},' \
            '"marketing_team":{' \
            '"name":"Marketing Team",' \
            '"leader":{"first_name":"Some","last_name":"Mark","title":"Mark Leader"},' \
            '"members":[{"first_name":"Another","last_name":"Dev","title":"Dev"}]}}'
        end
        it('to_hash  ') { expect_same_hash hsh, subject.to_hash }
        it('as_json  ') { expect_same_hash hsh, subject.as_json }
        it('to_json  ') { expect(subject.to_json).to eq(json) }
        it('from hash') { expect(subject).to eq(described_class.new(subject.to_hash)) }
        it('from json') { expect(subject).to eq(described_class.from_json(subject.to_json)) }
      end
    end
    context 'partial' do
      let(:params) { full_params.except :legal_name }
      let(:errors) { { legal_name: ["can't be blank"] } }
      let(:messages) { ["Legal name can't be blank"] }
      it { expect(subject).to_not be_valid }
      it { expect(subject.legal_name).to eq nil }
      it { expect(subject.development_team).to be_a team_class }
      it { expect(subject.development_team).to eq dev_team }
      it { expect(subject.marketing_team).to be_a team_class }
      it { expect(subject.marketing_team).to eq mark_team }
      it { expect(subject.errors).to be_a ActiveModel::Errors }
      it { expect(subject.errors.to_hash).to eq errors }
      it { expect(subject.errors.full_messages).to eq messages }
    end
  end
end
