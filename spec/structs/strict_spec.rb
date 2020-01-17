# frozen_string_literal: true

require 'spec_helper'

module FieldStruct
  module StrictExamples
    class User < FieldStruct.strict
      required :username, :string, format: /\A[a-z]/i
      optional :password, :string
      required :age, :integer
      required :owed, :float
      required :source, :string, enum: %w[A B C]
      required :level, :integer, default: -> { 2 }
      optional :at, :time
      optional :active, :boolean, default: false
    end

    class Person < FieldStruct.strict
      required :first_name, :string
      required :last_name, :string

      def full_name
        format '%s %s', first_name, last_name
      end
    end

    class Employee < Person
      extras :add
      optional :title, :string
    end

    class Developer < Employee
      required :language, :string
    end

    class Team < FieldStruct.strict
      required :name, :string
      required :leader, Employee
    end

    class Company < FieldStruct.strict
      required :legal_name, :string
      optional :development_team, Team
      optional :marketing_team, Team
    end
  end
end

RSpec.describe FieldStruct::StrictExamples::User do
  describe 'class' do
    it { expect(described_class.model_name).to be_a ActiveModel::Name }
    it { expect(described_class.extras).to eq :raise }
    context '.metadata' do
      subject { described_class.metadata }
      it { expect(subject.name).to eq 'FieldStruct::StrictExamples::User' }
      it { expect(subject.schema_name).to eq 'field_struct.strict_examples.user' }
      it { expect(subject.type).to eq :strict }
      it { expect(subject.version).to eq '7d1bd1cb' }
      it { expect(subject.keys).to eq %i[username password age owed source level at active] }
      it { expect(subject[:username]).to eq type: :string, required: true, format: /\A[a-z]/i }
      it { expect(subject[:password]).to eq type: :string }
      it { expect(subject[:age]).to eq type: :integer, required: true }
      it { expect(subject[:owed]).to eq type: :float, required: true }
      it { expect(subject[:source]).to eq type: :string, required: true, enum: %w[A B C] }
      it { expect(subject[:level]).to eq type: :integer, required: true, default: '<proc>' }
      it { expect(subject[:at]).to eq type: :time }
      it { expect(subject[:active]).to eq type: :boolean, default: false }
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
    context 'partial' do
      let(:params) { full_params.except :source, :level, :at, :active }
      let(:errors) { [":source can't be blank"] }
      it 'raises an error' do
        expect { subject }.to raise_error do |error|
          expect(error).to be_a FieldStruct::BuildError
          expect(error.message).to eq errors.first
          expect(error.errors).to eq errors
        end
      end
    end
  end
end

RSpec.describe FieldStruct::StrictExamples::Person do
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
      let(:errors) { [":last_name can't be blank"] }
      it 'raises an error' do
        expect { subject }.to raise_error do |error|
          expect(error).to be_a FieldStruct::BuildError
          expect(error.message).to eq errors.first
          expect(error.errors).to eq errors
        end
      end
    end
  end
end

RSpec.describe FieldStruct::StrictExamples::Employee do
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
      let(:errors) { [":last_name can't be blank"] }
      it 'raises an error' do
        expect { subject }.to raise_error do |error|
          expect(error).to be_a FieldStruct::BuildError
          expect(error.message).to eq errors.first
          expect(error.errors).to eq errors
        end
      end
    end
  end
end

RSpec.describe FieldStruct::StrictExamples::Developer do
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
      let(:errors) { [":last_name can't be blank"] }
      it 'raises an error' do
        expect { subject }.to raise_error do |error|
          expect(error).to be_a FieldStruct::BuildError
          expect(error.message).to eq errors.first
          expect(error.errors).to eq errors
        end
      end
    end
  end
end

RSpec.describe FieldStruct::StrictExamples::Team do
  describe 'class' do
    it { expect(described_class.model_name).to be_a ActiveModel::Name }
    it { expect(described_class.extras).to eq :raise }
    context '.attribute_types' do
      subject { described_class.attribute_types }
      it { expect(subject).to be_a Hash }
      it { expect(subject.keys).to eq %w[name leader] }
      it { expect(subject['name']).to be_a ActiveModel::Type::String }
      it { expect(subject['leader']).to eq FieldStruct::StrictExamples::Employee }
    end
  end
  describe 'instance' do
    let(:full_params) do
      basic_hash name: 'My Team',
                 leader: { first_name: 'Some', last_name: 'Person', title: 'Leader' }
    end
    subject { described_class.new params }
    let(:leader_class) { FieldStruct::StrictExamples::Employee }
    let(:leader) { leader_class.new full_params[:leader] }
    context 'full hash only' do
      let(:params) { full_params }
      it { expect(subject).to be_valid }
      it { expect(subject.name).to eq 'My Team' }
      it { expect(subject.leader).to be_a leader_class }
      it { expect(subject.leader.to_hash).to eq params[:leader] }
      it { expect(subject.leader).to eq leader }
    end
    context 'hash with struct' do
      let(:params) { full_params.merge leader: leader }
      it { expect(subject).to be_valid }
      it { expect(subject.name).to eq 'My Team' }
      it { expect(subject.leader).to be_a leader_class }
      it { expect(subject.leader).to eq leader }
    end
    context 'partial' do
      let(:params) { full_params.except :leader }
      let(:errors) { [":leader can't be blank"] }
      it 'raises an error' do
        expect { subject }.to raise_error do |error|
          expect(error).to be_a FieldStruct::BuildError
          expect(error.message).to eq errors.first
          expect(error.errors).to eq errors
        end
      end
    end
  end
end

RSpec.describe FieldStruct::StrictExamples::Company do
  describe 'class' do
    it { expect(described_class.model_name).to be_a ActiveModel::Name }
    it { expect(described_class.extras).to eq :raise }
    context '.attribute_types' do
      subject { described_class.attribute_types }
      it { expect(subject).to be_a Hash }
      it { expect(subject.keys).to eq %w[legal_name development_team marketing_team] }
      it { expect(subject['legal_name']).to be_a ActiveModel::Type::String }
      it { expect(subject['development_team']).to eq FieldStruct::StrictExamples::Team }
      it { expect(subject['marketing_team']).to eq FieldStruct::StrictExamples::Team }
    end
  end
  describe 'instance' do
    let(:full_params) do
      basic_hash          legal_name: 'My Company',
                          development_team: {
                            name: 'Dev Team',
                            leader: { first_name: 'Some', last_name: 'Dev', title: 'Dev Leader' }
                          },
                          marketing_team: {
                            name: 'Marketing Team',
                            leader: { first_name: 'Some', last_name: 'Marketroid', title: 'Marketroid Leader' }
                          }
    end
    subject { described_class.new params }
    let(:leader_class) { FieldStruct::StrictExamples::Employee }
    let(:team_class) { FieldStruct::StrictExamples::Team }
    let(:dev_team) { team_class.new full_params[:development_team] }
    let(:dev_team_leader) { leader_class.new full_params[:development_team][:leader] }
    let(:mark_team) { team_class.new full_params[:marketing_team] }
    let(:mark_team_leader) { leader_class.new full_params[:marketing_team][:leader] }
    context 'full hash only' do
      let(:params) { full_params }
      it { expect(subject).to be_valid }
      it { expect(subject.legal_name).to eq 'My Company' }
      it { expect(subject.development_team).to be_a team_class }
      it { expect(subject.development_team).to eq dev_team }
      it { expect(subject.marketing_team).to be_a team_class }
      it { expect(subject.marketing_team).to eq mark_team }
    end
    context 'hash with struct' do
      let(:params) { full_params.merge development_team: dev_team, marketing_team: mark_team }
      it { expect(subject).to be_valid }
      it { expect(subject.legal_name).to eq 'My Company' }
      it { expect(subject.development_team).to be_a team_class }
      it { expect(subject.development_team).to eq dev_team }
      it { expect(subject.marketing_team).to be_a team_class }
      it { expect(subject.marketing_team).to eq mark_team }
    end
    context 'partial' do
      let(:params) { full_params.except :legal_name }
      let(:errors) { [":legal_name can't be blank"] }
      it 'raises an error' do
        expect { subject }.to raise_error do |error|
          expect(error).to be_a FieldStruct::BuildError
          expect(error.message).to eq errors.first
          expect(error.errors).to eq errors
        end
      end
    end
  end
end
