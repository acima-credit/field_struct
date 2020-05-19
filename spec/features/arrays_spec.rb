# frozen_string_literal: true

module FieldStruct
  module ArrayExamples
    class FriendlyUser < FieldStruct.mutable
      required :username, :string
      required :friend_names, :array, of: :string
      required :friend_names2, :string, array: true
    end
  end
end

RSpec.describe FieldStruct do
  describe 'array_attributes' do
    let(:klass) { FieldStruct::ArrayExamples::FriendlyUser }
    context 'instances' do
      subject { klass.from attrs }
      context 'empty' do
        let(:attrs) { {} }
        it 'builds a proper instance' do
          expect { subject }.to_not raise_error
          expect(subject).to_not be_valid
          expect(subject.username).to be_nil
          expect(subject.friend_names).to be_nil
        end
      end
      context 'basic' do
        let(:attrs) do
          {
            username: 'george',
            friend_names: ['Mark'],
            friend_names2: ['Mark']
          }
        end
        it 'builds a proper instance' do
          expect { subject }.to_not raise_error
          expect(subject).to be_valid
          expect(subject.username).to eq 'george'
          expect(subject.friend_names).to eq ['Mark']
          expect(subject.friend_names).to eq ['Mark']
        end
      end
      context 'casted' do
        let(:attrs) do
          {
            username: 'george',
            friend_names: 'Mark',
            friend_names2: 'Mark'
          }
        end
        it 'builds a proper instance' do
          expect { subject }.to_not raise_error
          expect(subject).to be_valid
          expect(subject.username).to eq 'george'
          expect(subject.friend_names).to eq ['Mark']
          expect(subject.friend_names2).to eq 'Mark'
        end
      end
    end
  end
end
