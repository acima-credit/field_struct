# frozen_string_literal: true

require 'spec_helper'

module FieldedStruct
  module Examples
    class TypedUser < FieldedStruct::Basic
      plugin :typed_attribute_values

      attribute :username, :string
      attribute :password, :string
      attribute :email, :string
      attribute :age, :integer
    end
  end
end

RSpec.describe FieldedStruct::Examples::TypedUser, type: :struct do
  describe 'class' do
    context 'info' do
      it { expect(described_class).to respond_to :fielded_struct? }
      it { expect(described_class.fielded_struct?).to eq true }
      it { expect(described_class).to respond_to :field_ancestor }
      it { expect(described_class.field_ancestor).to eq FieldedStruct::Basic }
      it { expect(described_class.name).to eq 'FieldedStruct::Examples::TypedUser' }
      it { expect(described_class.extras).to eq :ignore }
    end
    context '.metadata' do
      subject { described_class.metadata }
      it { expect(subject).to be_a described_class::Metadata }
      it { expect(subject.name).to eq 'FieldedStruct::Examples::TypedUser' }
      it { expect(subject.schema_name).to eq 'fielded_struct.examples.typed_user' }
      it { expect(subject.type).to eq :basic }
      it { expect(subject.version).to eq '8e6ecf96' }
      it { expect(subject.keys).to eq %i[username password email age] }
      it { expect(subject[:username]).to eq({ coercible: true, type: :string, name: 'username' }) }
      it { expect(subject[:password]).to eq({ coercible: true, type: :string, name: 'password' }) }
      it { expect(subject[:email]).to eq({ coercible: true, type: :string, name: 'email' }) }
      it { expect(subject[:age]).to eq({ coercible: true, type: :integer, name: 'age' }) }
      it do
        expect(subject.to_hash).to eq name: 'FieldedStruct::Examples::TypedUser',
                                      schema_name: 'fielded_struct.examples.typed_user',
                                      version: '8e6ecf96',
                                      attributes: {
                                        username: { coercible: true, type: :string, name: 'username' },
                                        password: { coercible: true, type: :string, name: 'password' },
                                        email: { coercible: true, type: :string, name: 'email' },
                                        age: { coercible: true, type: :integer, name: 'age' }
                                      }
      end
    end
  end
  describe 'instance' do
    let(:full_params) do
      basic_hash username: 'some_user',
                 password: '123',
                 email: 'some_user@example.com',
                 age: '9'
    end
    subject { described_class.new params }
    context 'full' do
      let(:params) { full_params }
      context 'attributes' do
        it do
          expect(subject.attributes).to eq({
                                             username: 'some_user',
                                             password: '123',
                                             email: 'some_user@example.com',
                                             age: 9
                                           })
        end
        it { expect(subject.username).to eq 'some_user' }
        it { expect(subject.password).to eq '123' }
        it { expect(subject.email).to eq 'some_user@example.com' }
        it { expect(subject.age).to eq 9 }
        it do
          expect(subject.to_hash).to eq({
                                          username: 'some_user',
                                          password: '123',
                                          email: 'some_user@example.com',
                                          age: 9
                                        })
        end
      end
      it('to_s') {
        expect(subject.to_s).to eq '#<FieldedStruct::Examples::TypedUser username="some_user" ' \
                                   'password="123" email="some_user@example.com" age=9>'
      }
      context 'mutability' do
        it do
          expect { subject.age = 10 }.to_not raise_error
          expect(subject.age).to eq 10
        end
      end
    end
    context 'partial' do
      let(:params) { full_params.except :email, :password }
      context 'attributes' do
        it do
          expect(subject.attributes).to eq({
                                             username: 'some_user',
                                             password: nil,
                                             email: nil,
                                             age: 9
                                           })
        end
        it { expect(subject.username).to eq 'some_user' }
        it { expect(subject.password).to be_nil }
        it { expect(subject.email).to be_nil }
        it { expect(subject.age).to eq 9 }
        it do
          expect(subject.to_hash).to eq({
                                          username: 'some_user',
                                          password: nil,
                                          email: nil,
                                          age: 9
                                        })
        end
      end
      it('to_s') {
        expect(subject.to_s).to eq '#<FieldedStruct::Examples::TypedUser username="some_user" age=9>'
      }
    end
    context 'empty' do
      let(:params) { {} }
      context 'attributes' do
        it do
          expect(subject.attributes).to eq({
                                             username: nil,
                                             password: nil,
                                             email: nil,
                                             age: nil
                                           })
        end
        it { expect(subject.username).to be_nil }
        it { expect(subject.password).to be_nil }
        it { expect(subject.email).to be_nil }
        it { expect(subject.age).to be_nil }
        it do
          expect(subject.to_hash).to eq({
                                          username: nil,
                                          password: nil,
                                          email: nil,
                                          age: nil
                                        })
        end
      end
      it('to_s') {
        expect(subject.to_s).to eq '#<FieldedStruct::Examples::TypedUser>'
      }
    end
  end
end
