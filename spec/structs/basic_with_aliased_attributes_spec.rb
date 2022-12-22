# frozen_string_literal: true

require 'spec_helper'

module FieldedStruct
  module Examples
    class AliasedUser < FieldedStruct::Basic
      plugin :aliased_attributes

      attribute :UserName, alias: %i[username user_name]
      attribute :Password, alias: :password
    end
  end
end

RSpec.describe FieldedStruct::Examples::AliasedUser, type: :struct do
  describe 'class' do
    context 'info' do
      it { expect(described_class).to respond_to :fielded_struct? }
      it { expect(described_class.fielded_struct?).to eq true }
      it { expect(described_class).to respond_to :field_ancestor }
      it { expect(described_class.field_ancestor).to eq FieldedStruct::Basic }
      it { expect(described_class.name).to eq 'FieldedStruct::Examples::AliasedUser' }
      it { expect(described_class.extras).to eq :ignore }
    end
    context '.metadata' do
      subject { described_class.metadata }
      it { expect(subject).to be_a described_class::Metadata }
      it { expect(subject.name).to eq 'FieldedStruct::Examples::AliasedUser' }
      it { expect(subject.schema_name).to eq 'fielded_struct.examples.aliased_user' }
      it { expect(subject.type).to eq :basic }
      it { expect(subject.version).to eq '9deba98c' }
      it { expect(subject.keys).to eq %i[UserName Password] }
      it {
        expect(subject[:UserName]).to eq({ required: false, alias: %i[username user_name], name: 'UserName' })
      }
      it { expect(subject[:Password]).to eq({ required: false, alias: :password, name: 'Password' }) }
      it do
        expect(subject.to_hash).to eq name: 'FieldedStruct::Examples::AliasedUser',
                                      schema_name: 'fielded_struct.examples.aliased_user',
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
        it do
          expect(subject.attributes).to eq({
                                             UserName: 'some_user',
                                             Password: '123'
                                           })
        end
        it { expect(subject.UserName).to eq 'some_user' }
        it { expect(subject.username).to eq 'some_user' }
        it { expect(subject.user_name).to eq 'some_user' }
        it { expect(subject.Password).to eq '123' }
        it { expect(subject.password).to eq '123' }
        it do
          expect(subject.to_hash).to eq({
                                          UserName: 'some_user',
                                          Password: '123'
                                        })
        end
      end
      it('to_s') {
        expect(subject.to_s).to eq '#<FieldedStruct::Examples::AliasedUser UserName="some_user" Password="123">'
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
        it do
          expect(subject.attributes).to eq({
                                             UserName: 'some_user',
                                             Password: nil
                                           })
        end
        it { expect(subject.username).to eq 'some_user' }
        it do
          expect(subject.to_hash).to eq({
                                          UserName: 'some_user',
                                          Password: nil
                                        })
        end
      end
      it {
        expect(subject.to_s).to eq '#<FieldedStruct::Examples::AliasedUser UserName="some_user">'
      }
    end
    context 'empty' do
      let(:params) { {} }
      context 'attributes' do
        it do
          expect(subject.attributes).to eq({
                                             UserName: nil,
                                             Password: nil
                                           })
        end
        it { expect(subject.username).to eq nil }
        it do
          expect(subject.to_hash).to eq({
                                          UserName: nil,
                                          Password: nil
                                        })
        end
      end
      it {
        expect(subject.to_s).to eq '#<FieldedStruct::Examples::AliasedUser>'
      }
    end
  end
end
