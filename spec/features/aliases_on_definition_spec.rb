# frozen_string_literal: true

module FieldStruct
  module AliasesExamples
    class FriendlyUser < FieldStruct.mutable
      required :username, :string, alias: :user_name
      optional :first_name, :string, alias: %i[firstname given_name]
    end
  end
end

RSpec.describe FieldStruct do
  describe 'aliases' do
    let(:klass) { FieldStruct::AliasesExamples::FriendlyUser }
    context 'instances', :focus do
      subject { klass.from attrs }
      context 'empty' do
        let(:attrs) { {} }
        it 'builds a proper instance' do
          expect { subject }.to_not raise_error
          expect(subject).to_not be_valid
          expect(subject.username).to be_nil
          expect(subject.user_name).to be_nil
          expect(subject.first_name).to be_nil
          expect(subject.firstname).to be_nil
          expect(subject.given_name).to be_nil
          expect(subject.to_hash).to eq(
            'username' => nil,
            'first_name' => nil
          )
        end
      end
      context 'aliases on params' do
        let(:attrs) do
          {
            user_name: 'g1234',
            firstname: 'George'
          }
        end
        it 'builds a proper instance' do
          expect { subject }.to_not raise_error
          expect(subject).to be_valid
          expect(subject.username).to eq 'g1234'
          expect(subject.user_name).to eq 'g1234'
          expect(subject.first_name).to eq 'George'
          expect(subject.firstname).to eq 'George'
          expect(subject.given_name).to eq 'George'
          expect(subject.to_hash).to eq(
            'username' => 'g1234',
            'first_name' => 'George'
          )
        end
      end
    end
  end
end
