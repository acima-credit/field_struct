# frozen_string_literal: true

module FieldStruct
  module PropertyExamples
    class RequiredBooleanUser < FieldStruct.mutable
      required :username, :string
      required :privileged, :boolean
    end
  end
end

RSpec.describe FieldStruct do
  describe 'required booleans' do
    let(:klass) { FieldStruct::PropertyExamples::RequiredBooleanUser }
    context 'instances' do
      subject { klass.from attrs }
      shared_examples 'a proper boolean handler' do |value, exp_value|
        let(:attrs) { { username: 'george', privileged: value } }
        it('no error') { expect { subject }.to_not raise_error }
        it('valid') { expect(subject).to be_valid }
        it('no error messages') { expect(subject.errors.full_messages).to eq [] }
        it('username') { expect(subject.username).to eq 'george' }
        it('privileged') { expect(subject.privileged).to eq exp_value }
        it('to_hash') { expect(subject.to_hash).to eq('username' => 'george', 'privileged' => exp_value) }
        it('to_json') { expect(subject.to_json).to eq %({"username":"george","privileged":#{exp_value}}) }
      end
      context 'positive' do
        it_should_behave_like 'a proper boolean handler', true, true
        it_should_behave_like 'a proper boolean handler', 'true', true
        it_should_behave_like 'a proper boolean handler', 'TRUE', true
        it_should_behave_like 'a proper boolean handler', 't', true
        it_should_behave_like 'a proper boolean handler', 'T', true
        it_should_behave_like 'a proper boolean handler', 'on', true
        it_should_behave_like 'a proper boolean handler', 'ON', true
        it_should_behave_like 'a proper boolean handler', 1, true
        it_should_behave_like 'a proper boolean handler', '1', true
      end
      context 'negative' do
        it_should_behave_like 'a proper boolean handler', false, false
        it_should_behave_like 'a proper boolean handler', 'false', false
        it_should_behave_like 'a proper boolean handler', 'FALSE', false
        it_should_behave_like 'a proper boolean handler', 'f', false
        it_should_behave_like 'a proper boolean handler', 'F', false
        it_should_behave_like 'a proper boolean handler', 'off', false
        it_should_behave_like 'a proper boolean handler', 'OFF', false
        it_should_behave_like 'a proper boolean handler', 0, false
        it_should_behave_like 'a proper boolean handler', '0', false
      end
    end
  end
end
