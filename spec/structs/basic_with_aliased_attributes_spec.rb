# frozen_string_literal: true

require 'spec_helper'

module FieldStruct
  module Examples
    class AliasedUser < FieldStruct::Basic
      plugin :aliased_attributes

      attribute :UserName, alias: %i[username user_name]
      attribute :Password, alias: :password
    end
  end
end

RSpec.describe FieldStruct::Examples::AliasedUser, type: :struct do
  describe 'class' do
    context 'info' do
      it { expect(described_class).to respond_to :field_struct? }
      it { expect(described_class.field_struct?).to eq true }
      it { expect(described_class).to respond_to :field_ancestor }
      it { expect(described_class.field_ancestor).to eq FieldStruct::Basic }
      it { expect(described_class.name).to eq 'FieldStruct::Examples::AliasedUser' }
      it { expect(described_class.extras).to eq :ignore }
    end
    context '.metadata' do
      subject { described_class.metadata }
      it { expect(subject).to be_a described_class::Metadata }
      it { expect(subject.name).to eq 'FieldStruct::Examples::AliasedUser' }
      it { expect(subject.schema_name).to eq 'field_struct.examples.aliased_user' }
      it { expect(subject.type).to eq :basic }
      it { expect(subject.version).to eq '9deba98c' }
      it { expect(subject.keys).to eq %i[UserName Password] }
      it {
        expect(subject[:UserName]).to eq({ required: false, alias: %i[username user_name], name: 'UserName' })
      }
      it { expect(subject[:Password]).to eq({ required: false, alias: :password, name: 'Password' }) }
      it do
        expect(subject.to_hash).to eq name: 'FieldStruct::Examples::AliasedUser',
                                      schema_name: 'field_struct.examples.aliased_user',
                                      version: '9deba98c',
                                      attributes: {
                                        UserName: { required: false, alias: %i[username user_name], name: 'UserName' },
                                        Password: { required: false, alias: :password, name: 'Password' }
                                      }
      end
    end
  end
  describe 'instance' do
    let(:full_params) do
      basic_hash UserName: 'some_user',
                 password: '123'
    end
    subject { described_class.new params }
    context 'full' do
      let(:params) { full_params }
      context 'attributes' do
        it { expect(subject.UserName).to eq 'some_user' }
        it { expect(subject.username).to eq 'some_user' }
        it { expect(subject.user_name).to eq 'some_user' }
        it { expect(subject.Password).to eq '123' }
        it { expect(subject.password).to eq '123' }
      end
      it('to_s') {
        expect(subject.to_s).to eq '#<FieldStruct::Examples::AliasedUser UserName="some_user" Password="123">'
      }
      context 'aliases assignment' do
        it do
          expect { subject.UserName = 'x' }.to_not raise_error
          expect(subject.username).to eq 'x'
        end
        it do
          expect { subject.username = 'x' }.to_not raise_error
          expect(subject.username).to eq 'x'
        end
        it do
          expect { subject.user_name = 'x' }.to_not raise_error
          expect(subject.username).to eq 'x'
        end
        it do
          expect { subject.Password = 'x' }.to_not raise_error
          expect(subject.password).to eq 'x'
        end
        it do
          expect { subject.password = 'x' }.to_not raise_error
          expect(subject.password).to eq 'x'
        end
      end
    end
    context 'partial' do
      let(:params) { full_params.except :password }
      context 'attributes' do
        it { expect(subject.username).to eq 'some_user' }
      end
      it {
        expect(subject.to_s).to eq '#<FieldStruct::Examples::AliasedUser UserName="some_user">'
      }
    end
  end
end
