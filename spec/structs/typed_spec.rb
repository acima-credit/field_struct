# frozen_string_literal: true

require 'spec_helper'

module FieldStruct
  module Examples
    class TypedUser < FieldStruct::Basic
      plugin :typed_attribute_values

      attribute :age, :integer
    end
  end
end

RSpec.describe FieldStruct::Examples::TypedUser, type: :struct do
  describe 'class' do
    context 'info' do
      it { expect(described_class).to respond_to :field_struct? }
      it { expect(described_class.field_struct?).to eq true }
      it { expect(described_class).to respond_to :field_ancestor }
      it { expect(described_class.field_ancestor).to eq FieldStruct::Basic }
      it { expect(described_class.name).to eq 'FieldStruct::Examples::TypedUser' }
      it { expect(described_class.extras).to eq :ignore }
    end
    context '.metadata' do
      subject { described_class.metadata }
      it { expect(subject).to be_a described_class::Metadata }
      it { expect(subject.name).to eq 'FieldStruct::Examples::TypedUser' }
      it { expect(subject.schema_name).to eq 'field_struct.examples.typed_user' }
      it { expect(subject.type).to eq :basic }
      it { expect(subject.version).to eq '6daa95f0' }
      it { expect(subject.keys).to eq %i[age] }
      it { expect(subject[:age]).to eq({ coercible: true, type: :integer, name: 'age' }) }
      it do
        expect(subject.to_hash).to eq name: 'FieldStruct::Examples::TypedUser',
                                      schema_name: 'field_struct.examples.typed_user',
                                      version: '6daa95f0',
                                      attributes: {
                                        age: { coercible: true, type: :integer, name: 'age' }
                                      }
      end
    end
  end
  describe 'instance' do
    let(:full_params) do
      basic_hash age: '9'
    end
    subject { described_class.new params }
    context 'full' do
      let(:params) { full_params }
      context 'attributes' do
        it { expect(subject.age).to eq 9 }
      end
      it('to_s') {
        expect(subject.to_s).to eq '#<FieldStruct::Examples::TypedUser age=9>'
      }
      context 'immutability' do
        it do
          expect { subject.age = 10 }.to_not raise_error
          expect(subject.age).to eq 10
        end
      end
    end
    # context 'partial' do
    #   let(:params) { full_params.except :email, :rank }
    #   context 'attributes' do
    #     it { expect(subject.age).to eq 10.5 }
    #     it { expect(subject.password).to eq '123' }
    #     it { expect(subject.email).to be_nil }
    #     it { expect(subject.rank).to be_nil }
    #   end
    #   it { expect(subject.to_s).to eq '#<FieldStruct::Examples::TypedUser age=9>' }
    # end
  end
end
