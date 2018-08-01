# frozen_string_literal: true

RSpec.describe Synaptical::Trainer do
  let(:network) { Synaptical::Architect::Perceptron.new(2, 3, 1) }
  let(:trainer) { described_class.new(network) }

  describe '#train' do
    subject(:train) { trainer.train(set) }

    let(:set) do
      [
        { input: [0, 0], output: [0] },
        { input: [0, 1], output: [1] },
        { input: [1, 0], output: [1] },
        { input: [1, 1], output: [0] }
      ]
    end

    it { is_expected.to be_a(described_class::Result) }

    describe 'network' do
      before { train }

      it { expect(network.activate([0, 0]).first).to be_within(0.1).of(0) }
    end
  end
end
