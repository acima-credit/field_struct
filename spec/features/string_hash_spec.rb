# frozen_string_literal: true

module FieldStruct
  module ArrayExamples
    class FriendlyMetaUser < FieldStruct.mutable
      required :username, :string
      optional :meta, :string_hash
      validate :valid_meta

      def valid_meta
        return if meta.nil?

        errors.add(:meta, 'has to have a job_title') unless meta['job_title'].present?
      end
    end
  end
end

RSpec.describe FieldStruct do
  describe 'string_hash_attributes' do
    let(:klass) { FieldStruct::ArrayExamples::FriendlyMetaUser }
    context 'instances' do
      subject { klass.from attrs }
      context 'empty' do
        let(:attrs) { {} }
        it 'builds a proper instance' do
          expect { subject }.to_not raise_error
          expect(subject).to_not be_valid
          expect(subject.errors.full_messages).to eq ["Username can't be blank"]
          expect(subject.username).to be_nil
          expect(subject.meta).to be_nil
          expect(subject.to_hash).to eq({ 'meta' => nil, 'username' => nil })
          expect(subject.to_json).to eq '{"username":null,"meta":null}'
          expect(subject).to_not be_valid
        end
      end
      context 'basic' do
        let(:attrs) do
          {
            username: 'george',
            meta: { first_name: 'John', last_name: 'Smith' }
          }
        end
        it 'builds a proper instance' do
          expect { subject }.to_not raise_error
          expect(subject).to_not be_valid
          expect(subject.errors.full_messages).to eq ['Meta has to have a job_title']
          expect(subject.username).to eq 'george'
          expect(subject.meta).to be_a ActiveSupport::HashWithIndifferentAccess
          expect(subject.meta).to eq({ 'first_name' => 'John', 'last_name' => 'Smith' })
          expect(subject.meta[:first_name]).to eq 'John'
          expect(subject.meta['first_name']).to eq 'John'
          expect(subject.meta[:last_name]).to eq 'Smith'
          expect(subject.meta['last_name']).to eq 'Smith'
          expect(subject.meta[:title]).to be_nil
          expect(subject.meta['title']).to be_nil
          expect(subject.to_hash).to eq({
                                          'username' => 'george',
                                          'meta' => {
                                            'first_name' => 'John',
                                            'last_name' => 'Smith'
                                          }
                                        })
          expect(subject.to_json).to eq '{"username":"george","meta":{"first_name":"John","last_name":"Smith"}}'
        end
      end
      context 'full' do
        let(:attrs) do
          {
            username: 'george',
            meta: {
              first_name: 'John',
              last_name: 'Smith',
              job_title: 'Developer',
              age: 45,
              balance: 123.45
            }
          }
        end
        it 'builds a proper instance' do
          expect { subject }.to_not raise_error
          expect(subject).to be_valid
          expect(subject.errors.full_messages).to eq []
          expect(subject.username).to eq 'george'
          expect(subject.meta).to be_a ActiveSupport::HashWithIndifferentAccess
          expect(subject.meta).to eq({
                                       'first_name' => 'John',
                                       'last_name' => 'Smith',
                                       'job_title' => 'Developer',
                                       'age' => '45',
                                       'balance' => '123.45'
                                     })
          expect(subject.meta[:first_name]).to eq 'John'
          expect(subject.meta['first_name']).to eq 'John'
          expect(subject.meta[:last_name]).to eq 'Smith'
          expect(subject.meta['last_name']).to eq 'Smith'
          expect(subject.meta[:job_title]).to eq 'Developer'
          expect(subject.meta['job_title']).to eq 'Developer'
          expect(subject.meta[:age]).to eq '45'
          expect(subject.meta['age']).to eq '45'
          expect(subject.meta[:balance]).to eq '123.45'
          expect(subject.meta['balance']).to eq '123.45'
          expect(subject.to_hash).to eq({
                                          'username' => 'george',
                                          'meta' => {
                                            'first_name' => 'John',
                                            'last_name' => 'Smith',
                                            'job_title' => 'Developer',
                                            'age' => '45',
                                            'balance' => '123.45'
                                          }
                                        })
          expect(subject.to_json).to eq '{"username":"george",' \
                                        '"meta":{' \
                                        '"first_name":"John",' \
                                        '"last_name":"Smith",' \
                                        '"job_title":"Developer",' \
                                        '"age":"45",' \
                                        '"balance":"123.45"' \
                                        '}}'
        end
      end
    end
  end
end
