# frozen_string_literal: true

require 'spec_helper'

module FieldStruct
  module MutableExamples
    class User < FieldStruct.mutable
      required :username, :string, format: /\A[a-z]/i
      optional :password, :string
      required :age, :integer
      required :owed, :currency
      required :source, :string, enum: %w[A B C]
      required :level, :integer, default: -> { 2 }
      optional :at, :time
      optional :active, :boolean, default: false
    end

    class Person < FieldStruct.mutable
      required :first_name, :string
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

    class Team < FieldStruct.mutable
      required :name, :string
      required :leader, Employee
      required :members, :array, of: Employee
    end

    class Company < FieldStruct.mutable
      required :legal_name, :string
      optional :development_team, Team
      optional :marketing_team, Team
    end
  end
end

RSpec.describe FieldStruct::MutableExamples::User do
  describe 'class' do
    it { expect(described_class.model_name).to be_a ActiveModel::Name }
    it { expect(described_class.extras).to eq :raise }
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
      end
      context 'immutability' do
        it do
          expect { subject.username = 'x' }.to_not raise_error
          expect(subject.username).to eq 'x'
        end
        it do
          expect { subject.password = 'x' }.to_not raise_error
          expect(subject.password).to eq 'x'
        end
        it do
          expect { subject.age = 33 }.to_not raise_error
          expect(subject.age).to eq 33
        end
        it do
          expect { subject.owed = 12.34 }.to_not raise_error
          expect(subject.owed).to eq 12.34
        end
        it do
          expect { subject.source = 'C' }.to_not raise_error
          expect(subject.source).to eq 'C'
        end
        it do
          expect { subject.level = 1 }.to_not raise_error
          expect(subject.level).to eq 1
        end
        it do
          expect { subject.at = Time.parse('2018-04-15') }.to_not raise_error
          expect(subject.at).to eq Time.parse('2018-04-15')
        end
        it do
          expect { subject.active = true }.to_not raise_error
          expect(subject.active).to eq true
        end
      end
      context 'coercion' do
        context 'username' do
          context '100' do
            let(:username) { '100' }
            it { expect(subject.username).to eq '100' }
          end
          context 'true' do
            let(:username) { true }
            it { expect(subject.username).to eq 't' }
          end
        end
        context 'age' do
          context '100' do
            let(:age) { '100' }
            it { expect(subject.age).to eq 100 }
          end
          context 'true' do
            let(:age) { true }
            it { expect(subject.age).to eq 1 }
          end
          context '50.5' do
            let(:age) { 50.6 }
            it { expect(subject.age).to eq 50 }
          end
          context '-50.5' do
            let(:age) { -50.6 }
            it { expect(subject.age).to eq(-50) }
          end
        end
        context 'owed' do
          context '$50.00' do
            let(:owed) { '$50.00' }
            it { expect(subject.owed).to eq 50.0 }
          end
          context '50' do
            let(:owed) { 50 }
            it { expect(subject.owed).to eq 50.0 }
          end
          context 'BD 50.00' do
            let(:owed) { BigDecimal('50.0') }
            it { expect(subject.owed).to eq 50.0 }
          end
          context 'wrong' do
            let(:owed) { 'wrong' }
            it { expect(subject.owed).to eq nil }
          end
          context '$3.o1' do
            let(:owed) { '$3.o1' }
            it { expect(subject.owed).to eq nil }
          end
        end
        context 'active' do
          context 'true' do
            let(:active) { 'true' }
            it { expect(subject.active).to eq true }
          end
          context 't' do
            let(:active) { 't' }
            it { expect(subject.active).to eq true }
          end
          context '1' do
            let(:active) { 1 }
            it { expect(subject.active).to eq true }
          end
          context 'yes' do
            let(:active) { 'yes' }
            it { expect(subject.active).to eq true }
          end
          context 'y' do
            let(:active) { 'y' }
            it { expect(subject.active).to eq true }
          end
          context 'false' do
            let(:active) { 'false' }
            it { expect(subject.active).to eq false }
          end
          context 't' do
            let(:active) { 'f' }
            it { expect(subject.active).to eq false }
          end
          context '0' do
            let(:active) { 0 }
            it { expect(subject.active).to eq false }
          end
        end
      end
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

RSpec.describe FieldStruct::MutableExamples::Person do
  describe 'class' do
    it { expect(described_class.model_name).to be_a ActiveModel::Name }
    it { expect(described_class.extras).to eq :raise }
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

RSpec.describe FieldStruct::MutableExamples::Employee do
  describe 'class' do
    it { expect(described_class.model_name).to be_a ActiveModel::Name }
    it { expect(described_class.extras).to eq :add }
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

RSpec.describe FieldStruct::MutableExamples::Developer do
  describe 'class' do
    it { expect(described_class.model_name).to be_a ActiveModel::Name }
    it { expect(described_class.extras).to eq :add }
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

RSpec.describe FieldStruct::MutableExamples::Team do
  let(:leader_class) { FieldStruct::MutableExamples::Employee }
  let(:member_class) { leader_class }
  describe 'class' do
    it { expect(described_class.model_name).to be_a ActiveModel::Name }
    it { expect(described_class.extras).to eq :raise }
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
    end
    context 'hash with struct' do
      let(:params) { full_params.merge leader: leader }
      it { expect(subject).to be_valid }
      it { expect(subject.name).to eq 'My Team' }
      it { expect(subject.leader).to be_a leader_class }
      it { expect(subject.leader).to eq leader }
      it { expect(subject.members).to eq [dev1, dev2] }
    end
    context 'partial' do
      let(:params) { full_params.except(:leader).update(members: []) }
      let(:errors) { { leader: ["can't be blank"], members: ["can't be blank"] } }
      let(:messages) { ["Leader can't be blank", "Members can't be blank"] }
      it { expect(subject).to_not be_valid }
      it { expect(subject.name).to eq 'My Team' }
      it { expect(subject.leader).to eq nil }
      it { expect(subject.members).to eq [] }
      it { expect(subject.errors).to be_a ActiveModel::Errors }
      it { expect(subject.errors.to_hash).to eq errors }
      it { expect(subject.errors.full_messages).to eq messages }
      context 'validations', :focus do
        context 'with invalid leader' do
          let(:params) { full_params.tap { |x| x[:leader].delete :first_name } }
          it { expect(subject).to_not be_valid }
          it { expect(subject.leader).to_not be_valid }
          it { expect(subject.errors.to_hash).to eq(leader: ["first_name can't be blank"]) }
        end
      end
    end
  end
end

RSpec.describe FieldStruct::MutableExamples::Company do
  describe 'class' do
    it { expect(described_class.model_name).to be_a ActiveModel::Name }
    it { expect(described_class.extras).to eq :raise }
    context '.attribute_types' do
      subject { described_class.attribute_types }
      it { expect(subject).to be_a Hash }
      it { expect(subject.keys).to eq %w[legal_name development_team marketing_team] }
      it { expect(subject['legal_name']).to be_a ActiveModel::Type::String }
      it { expect(subject['development_team']).to eq FieldStruct::MutableExamples::Team }
      it { expect(subject['marketing_team']).to eq FieldStruct::MutableExamples::Team }
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
    let(:leader_class) { FieldStruct::MutableExamples::Employee }
    let(:team_class) { FieldStruct::MutableExamples::Team }
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
