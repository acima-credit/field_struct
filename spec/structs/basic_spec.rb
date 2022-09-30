# frozen_string_literal: true

require 'spec_helper'

module FieldStruct
  module Examples
    class BasicUser < FieldStruct::Basic
      RANKS = %w[freshman senior].freeze

      attribute :username
      attribute :password
      attribute :email
      attribute :rank, enum: RANKS, default: RANKS.first
    end

    class BasicInheritedUser < BasicUser
      attribute :level, default: 1
    end
  end
end

RSpec.describe FieldStruct::Examples::BasicUser, type: :struct do
  describe 'class' do
    context 'info' do
      it { expect(described_class).to respond_to :field_struct? }
      it { expect(described_class.field_struct?).to eq true }
      it { expect(described_class).to respond_to :field_ancestor }
      it { expect(described_class.field_ancestor).to eq FieldStruct::Basic }
      it { expect(described_class.name).to eq 'FieldStruct::Examples::BasicUser' }
      it { expect(described_class.extras).to eq :ignore }
    end
    context '.metadata' do
      subject { described_class.metadata }
      it { expect(subject).to be_a described_class::Metadata }
      it { expect(subject.name).to eq 'FieldStruct::Examples::BasicUser' }
      it { expect(subject.schema_name).to eq 'field_struct.examples.basic_user' }
      it { expect(subject.type).to eq :basic }
      it { expect(subject.version).to eq '724ad77a' }
      it { expect(subject.keys).to eq %i[username password email rank] }
      it { expect(subject[:username]).to eq({ required: false, name: 'username' }) }
      it { expect(subject[:password]).to eq({ required: false, name: 'password' }) }
      it { expect(subject[:email]).to eq({ required: false, name: 'email' }) }
      it {
        expect(subject[:rank]).to eq({ required: false, name: 'rank', enum: %w[freshman senior], default: 'freshman' })
      }
      it do
        expect(subject.to_hash).to eq name: 'FieldStruct::Examples::BasicUser',
                                      schema_name: 'field_struct.examples.basic_user',
                                      version: '724ad77a',
                                      attributes: {
                                        username: { required: false, name: 'username' },
                                        password: { required: false, name: 'password' },
                                        email: { required: false, name: 'email' },
                                        rank: { required: false, name: 'rank', enum: %w[freshman senior],
                                                default: 'freshman' }
                                      }
      end
    end
  end
  describe 'instance' do
    let(:full_params) do
      basic_hash username: 'some_user',
                 password: '123',
                 email: 'some_user@example.com',
                 rank: 'senior'
    end
    subject { described_class.new params }
    context 'full' do
      let(:params) { full_params }
      context 'attributes' do
        it { expect(subject.username).to eq 'some_user' }
        it { expect(subject.password).to eq '123' }
        it { expect(subject.email).to eq 'some_user@example.com' }
        it { expect(subject.rank).to eq 'senior' }
      end
      it('to_s') {
        expect(subject.to_s).to eq '#<FieldStruct::Examples::BasicUser username="some_user" password="123" ' \
                                   'email="some_user@example.com" rank="senior">'
      }
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
          expect { subject.email = 'some_email@example.com' }.to_not raise_error
          expect(subject.email).to eq 'some_email@example.com'
        end
        it do
          expect { subject.rank = 'junior' }.to_not raise_error
          expect(subject.rank).to eq 'junior'
        end
      end
    end
    context 'partial' do
      let(:params) { full_params.except :email, :rank }
      context 'attributes' do
        it { expect(subject.username).to eq 'some_user' }
        it { expect(subject.password).to eq '123' }
        it { expect(subject.email).to be_nil }
        it { expect(subject.rank).to be_nil }
      end
      it { expect(subject.to_s).to eq '#<FieldStruct::Examples::BasicUser username="some_user" password="123">' }
    end
  end
end

RSpec.describe FieldStruct::Examples::BasicInheritedUser, type: :struct do
  describe 'class' do
    context 'info' do
      it { expect(described_class).to respond_to :field_struct? }
      it { expect(described_class.field_struct?).to eq true }
      it { expect(described_class).to respond_to :field_ancestor }
      it { expect(described_class.field_ancestor).to eq FieldStruct::Examples::BasicUser }
      it { expect(described_class.name).to eq 'FieldStruct::Examples::BasicInheritedUser' }
      it { expect(described_class.extras).to eq :ignore }
    end
    context '.metadata' do
      subject { described_class.metadata }
      it { expect(subject).to be_a described_class::Metadata }
      it { expect(subject.name).to eq 'FieldStruct::Examples::BasicInheritedUser' }
      it { expect(subject.schema_name).to eq 'field_struct.examples.basic_inherited_user' }
      it { expect(subject.type).to eq :basic }
      it { expect(subject.version).to eq '085f790e' }
      it { expect(subject.keys).to eq %i[username password email rank level] }
      it { expect(subject[:username]).to eq({ required: false, name: 'username' }) }
      it { expect(subject[:password]).to eq({ required: false, name: 'password' }) }
      it { expect(subject[:email]).to eq({ required: false, name: 'email' }) }
      it {
        expect(subject[:rank]).to eq({ required: false, name: 'rank', enum: %w[freshman senior], default: 'freshman' })
      }
      it { expect(subject[:level]).to eq({ required: false, name: 'level', default: 1 }) }
      it do
        expect(subject.to_hash).to eq name: 'FieldStruct::Examples::BasicInheritedUser',
                                      schema_name: 'field_struct.examples.basic_inherited_user',
                                      version: '085f790e',
                                      attributes: {
                                        username: { required: false, name: 'username' },
                                        password: { required: false, name: 'password' },
                                        email: { required: false, name: 'email' },
                                        rank: {
                                          required: false,
                                          name: 'rank',
                                          enum: %w[freshman senior],
                                          default: 'freshman'
                                        },
                                        level: { required: false, name: 'level', default: 1 }
                                      }
      end
    end
  end
  describe 'instance' do
    let(:full_params) do
      basic_hash username: 'some_user',
                 password: '123',
                 email: 'some_user@example.com',
                 rank: 'senior',
                 level: 3
    end
    subject { described_class.new params }
    context 'full' do
      let(:params) { full_params }
      context 'attributes' do
        it { expect(subject.username).to eq 'some_user' }
        it { expect(subject.password).to eq '123' }
        it { expect(subject.email).to eq 'some_user@example.com' }
        it { expect(subject.rank).to eq 'senior' }
        it { expect(subject.level).to eq 3 }
      end
      it('to_s') {
        expect(subject.to_s).to eq '#<FieldStruct::Examples::BasicInheritedUser username="some_user" password="123" ' \
                                   'email="some_user@example.com" rank="senior" level=3>'
      }
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
          expect { subject.email = 'some_email@example.com' }.to_not raise_error
          expect(subject.email).to eq 'some_email@example.com'
        end
        it do
          expect { subject.rank = 'freshman' }.to_not raise_error
          expect(subject.rank).to eq 'freshman'
        end
        it do
          expect { subject.level = 1 }.to_not raise_error
          expect(subject.level).to eq 1
        end
      end
    end
    context 'partial' do
      let(:params) { full_params.except :email, :level }
      context 'attributes' do
        it { expect(subject.username).to eq 'some_user' }
        it { expect(subject.password).to eq '123' }
        it { expect(subject.email).to be_nil }
        it { expect(subject.rank).to eq 'senior' }
        it { expect(subject.level).to be_nil }
      end
      it {
        expect(subject.to_s).to eq '#<FieldStruct::Examples::BasicInheritedUser username="some_user" password="123" ' \
                                   'rank="senior">'
      }
    end
  end
end
