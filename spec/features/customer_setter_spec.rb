# frozen_string_literal: true

module FieldStruct
  module PropertyExamples
    class FriendlyCustomUser < FieldStruct.mutable
      required :username, :string
      required :first_name, :string
      required :last_name, :string

      def full_name
        format '%s %s', first_name, last_name
      end

      def full_name=(value)
        parts = value.to_s.split(/\s+/)
        assign_attribute 'first_name', parts[0]
        assign_attribute :last_name, parts[1..-1].join(' ')
      end
    end
  end
end

RSpec.describe FieldStruct do
  describe 'custom properties' do
    let(:klass) { FieldStruct::PropertyExamples::FriendlyCustomUser }
    context 'instances' do
      subject { klass.from attrs }
      context 'custom setter' do
        let(:attrs) do
          {
            username: 'george',
            full_name: 'George Roberts'
          }
        end
        it 'builds a proper instance' do
          expect { subject }.to_not raise_error
          expect(subject).to be_valid
          expect(subject.errors.full_messages).to eq []
          expect(subject.username).to eq 'george'
          expect(subject.first_name).to eq 'George'
          expect(subject.last_name).to eq 'Roberts'
          expect(subject.to_hash).to eq(
            'username' => 'george',
            'first_name' => 'George',
            'last_name' => 'Roberts'
          )
          expect(subject.to_json).to eq '{"username":"george","first_name":"George","last_name":"Roberts"}'
        end
      end
      context 'normal' do
        let(:attrs) do
          {
            username: 'george',
            first_name: 'George',
            last_name: 'Roberts'
          }
        end
        it 'builds a proper instance' do
          expect { subject }.to_not raise_error
          expect(subject).to be_valid
          expect(subject.errors.full_messages).to eq []
          expect(subject.username).to eq 'george'
          expect(subject.first_name).to eq 'George'
          expect(subject.last_name).to eq 'Roberts'
          expect(subject.to_hash).to eq(
            'username' => 'george',
            'first_name' => 'George',
            'last_name' => 'Roberts'
          )
          expect(subject.to_json).to eq '{"username":"george","first_name":"George","last_name":"Roberts"}'
        end
      end
    end
  end
end
