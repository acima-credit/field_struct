# frozen_string_literal: true

require 'spec_helper'

module FieldedStruct
  module Examples
    class IgnoreExtrasUser < FieldedStruct::Basic
      # extras :ignore # default
      #
      attribute :username
    end

    class AddExtrasUser < FieldedStruct::Basic
      extras :add

      attribute :username
    end

    class RaiseExtrasUser < FieldedStruct::Basic
      extras :raise

      attribute :username
    end
  end
end

RSpec.describe 'feature : extras', type: :feature do
  describe FieldedStruct::Examples::IgnoreExtrasUser, type: :struct do
    describe 'class' do
      context 'info' do
        it { expect(described_class.name).to eq 'FieldedStruct::Examples::IgnoreExtrasUser' }
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
          expect(subject.to_s).to eq '#<FieldedStruct::Examples::IgnoreExtrasUser username="some_user">'
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
        it { expect(subject.to_s).to eq '#<FieldedStruct::Examples::IgnoreExtrasUser username="some_user">' }
      end
    end
  end
  describe FieldedStruct::Examples::AddExtrasUser, type: :struct do
    describe 'class' do
      context 'info' do
        it { expect(described_class.name).to eq 'FieldedStruct::Examples::AddExtrasUser' }
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
          expect(subject.to_s).to eq '#<FieldedStruct::Examples::AddExtrasUser username="some_user">'
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
        it { expect(subject.to_s).to eq '#<FieldedStruct::Examples::AddExtrasUser username="some_user">' }
      end
    end
  end
  describe FieldedStruct::Examples::RaiseExtrasUser, type: :struct do
    describe 'class' do
      context 'info' do
        it { expect(described_class.name).to eq 'FieldedStruct::Examples::RaiseExtrasUser' }
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
        let(:err_msg) { "unknown attribute 'password' for FieldedStruct::Examples::RaiseExtrasUser." }
        it 'works' do
          expect { subject }.to raise_error FieldedStruct::UnknownAttributeError, err_msg
        end
      end
      context 'partial' do
        let(:params) { full_params.except :email, :rank }
        context 'attributes' do
          let(:err_msg) { "unknown attribute 'password' for FieldedStruct::Examples::RaiseExtrasUser." }
          it 'works' do
            expect { subject }.to raise_error FieldedStruct::UnknownAttributeError, err_msg
          end
        end
      end
    end
  end
end
