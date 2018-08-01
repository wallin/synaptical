# frozen_string_literal: true

RSpec.describe Synaptical::Serializer::JSON do
  describe '::as_json' do
    subject(:as_json) { described_class.as_json(network) }

    let(:network) { Synaptical::Architect::Perceptron.new(1, 3, 2) }

    context 'with valid network' do
      it { is_expected.to be_a(Hash) }

      describe 'neurons.size' do
        subject { as_json[:neurons].size }

        it { is_expected.to eq 6 }
      end

      describe 'connections.size' do
        subject { as_json[:connections].size }

        it { is_expected.to eq 9 }
      end
    end

    context 'with invalid network' do
      let(:network) { 'invalid' }

      it { expect { as_json }.to raise_exception(ArgumentError) }
    end
  end

  describe '::load' do
    pending
  end
end
