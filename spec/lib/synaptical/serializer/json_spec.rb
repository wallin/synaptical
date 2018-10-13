# frozen_string_literal: true

RSpec.describe Synaptical::Serializer::JSON do
  let(:network) { Synaptical::Architect::Perceptron.new(2, 3, 1) }

  describe '::as_json' do
    subject(:as_json) { described_class.as_json(network) }

    context 'with valid network' do
      it { is_expected.to be_a(Hash) }

      describe 'neurons.size' do
        subject { as_json['neurons'].size }

        it { is_expected.to eq 6 }
      end

      describe 'connections.size' do
        subject { as_json['connections'].size }

        it { is_expected.to eq 9 }
      end
    end

    context 'with invalid network' do
      let(:network) { 'invalid' }

      it { expect { as_json }.to raise_exception(ArgumentError) }
    end
  end

  describe '::load' do
    subject(:from_json) { described_class.from_json(json) }

    let(:json) { described_class.as_json(network) }

    describe 'de-serialized network' do
      it { is_expected.to have_attributes(inputs: network.inputs, outputs: network.outputs) }
    end

    context 'with serialized XOR network' do
      subject { from_json.activate(input).first.round }

      before do
        Synaptical::Trainer.new(network).train(
          [
            { input: [0, 0], output: [0] },
            { input: [0, 1], output: [1] },
            { input: [1, 0], output: [1] },
            { input: [1, 1], output: [0] }
          ]
        )
      end

      describe 'when input is [0, 1]' do
        let(:input) { [0, 1] }

        it { is_expected.to eq 1 }
      end

      describe 'when input is [1, 1]' do
        let(:input) { [1, 1] }

        it { is_expected.to eq 0 }
      end
    end
  end
end
