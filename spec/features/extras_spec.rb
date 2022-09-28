# frozen_string_literal: true

require 'spec_helper'

module FieldStruct
  module Examples
    class IgnoreExtrasUser < FieldStruct::Basic
      # extras :ignore # default
      #
      attribute :username
    end

    class AddExtrasUser < FieldStruct::Basic
      extras :add

      attribute :username
    end

    class RaiseExtrasUser < FieldStruct::Basic
      extras :raise

      attribute :username
    end
  end
end

RSpec.describe 'feature : extras', type: :feature do
  describe FieldStruct::Examples::IgnoreExtrasUser, type: :struct do
    describe 'class' do
      context 'info' do
        it { expect(described_class.name).to eq 'FieldStruct::Examples::IgnoreExtrasUser' }
        it { expect(described_class.extras).to eq :ignore }
      end
      context '.metadata' do
        subject { described_class.metadata }
        it { expect(subject).to be_a described_class::Metadata }
        it { expect(subject.extras).to eq :ignore }
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
        it 'works' do
          expect { subject }.to_not raise_error
          expect(subject.username).to eq 'some_user'
          expect(subject.extras).to eq({})
        end
        it('to_s') {
          expect(subject.to_s).to eq '#<FieldStruct::Examples::IgnoreExtrasUser username="some_user">'
        }
        context 'assignment' do
          context 'username' do
            it do
              expect { subject.set :username, 'x' }.to_not raise_error
              expect(subject.username).to eq 'x'
            end
          end
          context 'other' do
            it do
              expect { subject.set :other, 'x' }.to_not raise_error
              expect(subject).to_not respond_to(:other)
              expect(subject.extras).to eq({})
            end
          end
        end
      end
      context 'partial' do
        let(:params) { full_params.except :email, :rank }
        context 'attributes' do
          it 'works' do
            expect { subject }.to_not raise_error
            expect(subject.username).to eq 'some_user'
            expect(subject.extras).to eq({})
          end
        end
        it { expect(subject.to_s).to eq '#<FieldStruct::Examples::IgnoreExtrasUser username="some_user">' }
      end
    end
  end
  describe FieldStruct::Examples::AddExtrasUser, type: :struct do
    describe 'class' do
      context 'info' do
        it { expect(described_class.name).to eq 'FieldStruct::Examples::AddExtrasUser' }
        it { expect(described_class.extras).to eq :add }
      end
      context '.metadata' do
        subject { described_class.metadata }
        it { expect(subject).to be_a described_class::Metadata }
        it { expect(subject.extras).to eq :add }
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
        it 'works' do
          expect { subject }.to_not raise_error
          expect(subject.username).to eq 'some_user'
          expect(subject.extras).to eq password: '123',
                                       email: 'some_user@example.com',
                                       rank: 'senior'
        end
        it('to_s') {
          expect(subject.to_s).to eq '#<FieldStruct::Examples::AddExtrasUser username="some_user">'
        }
        context 'assignment' do
          context 'username' do
            it do
              expect { subject.set :username, 'x' }.to_not raise_error
              expect(subject.username).to eq 'x'
            end
          end
          context 'other' do
            it do
              expect { subject.set :other, 'x' }.to_not raise_error
              expect(subject).to_not respond_to(:other)
              expect(subject.extras[:other]).to eq 'x'
            end
          end
        end
      end
      context 'partial' do
        let(:params) { full_params.except :email, :rank }
        context 'attributes' do
          it 'works' do
            expect { subject }.to_not raise_error
            expect(subject.username).to eq 'some_user'
            expect(subject.extras).to eq password: '123'
          end
        end
        it { expect(subject.to_s).to eq '#<FieldStruct::Examples::AddExtrasUser username="some_user">' }
      end
    end
  end
  describe FieldStruct::Examples::RaiseExtrasUser, type: :struct do
    describe 'class' do
      context 'info' do
        it { expect(described_class.name).to eq 'FieldStruct::Examples::RaiseExtrasUser' }
        it { expect(described_class.extras).to eq :raise }
      end
      context '.metadata' do
        subject { described_class.metadata }
        it { expect(subject).to be_a described_class::Metadata }
        it { expect(subject.extras).to eq :raise }
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
        let(:err_msg) { "unknown attribute 'password' for FieldStruct::Examples::RaiseExtrasUser." }
        it 'works' do
          expect { subject }.to raise_error FieldStruct::UnknownAttributeError, err_msg
        end
      end
      context 'partial' do
        let(:params) { full_params.except :email, :rank }
        context 'attributes' do
          let(:err_msg) { "unknown attribute 'password' for FieldStruct::Examples::RaiseExtrasUser." }
          it 'works' do
            expect { subject }.to raise_error FieldStruct::UnknownAttributeError, err_msg
          end
        end
      end
    end
  end
end
