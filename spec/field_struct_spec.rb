# frozen_string_literal: true

RSpec.describe FieldStruct do
  it 'has a version number' do
    expect(FieldStruct::VERSION).not_to be nil
  end
  describe 'unnamed classes' do
    let(:meta) { FieldStruct::Metadata.new name, nil, type, extras, attributes }
    let(:klass) { FieldStruct.from_metadata meta, prefix }
    let(:instance) { klass.new options }
    let(:type) { :flexible }
    let(:extras) { :ignore }
    let(:attributes) do
      {
        first_name: { type: :string, required: true },
        last_name: { type: :string, format: /\A[a-z]/i },
        age: { type: :integer, length: 0..100 }
      }
    end
    let(:options) { { first_name: 'Some', last_name: 'Person', age: 30 } }
    context 'without prefix' do
      let(:name) { 'My::Own::Person' }
      let(:schema_name) { 'my.own.person' }
      let(:prefix) { nil }
      it do
        expect { klass }.to_not raise_error
        expect(klass.name).to eq 'My::Own::Person'
        expect(klass.metadata.name).to eq 'My::Own::Person'
        expect(klass.metadata.schema_name).to eq 'my.own.person'

        expect { instance }.to_not raise_error
        expect(instance).to be_valid

        expect { klass.new }.to_not raise_error
        expect(klass.new).to_not be_valid
      end
    end
    context 'with prefix' do
      let(:name) { 'Person' }
      let(:schema_name) { 'my.other.person' }
      let(:prefix) { 'My::Other' }
      it do
        expect { klass }.to_not raise_error
        expect(klass.name).to eq 'My::Other::Person'
        expect(klass.metadata.name).to eq 'My::Other::Person'
        expect(klass.metadata.schema_name).to eq 'person'

        expect { instance }.to_not raise_error
        expect(instance).to be_valid

        expect { klass.new }.to_not raise_error
        expect(klass.new).to_not be_valid
      end
    end
  end
end
