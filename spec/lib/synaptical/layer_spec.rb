# frozen_string_literal: true

RSpec.describe Synaptical::Layer do
  let(:layer) { described_class.new(size) }

  describe '#add' do
    subject(:add) { layer.add(neuron) }

    let(:size) { 0 }
    let(:neuron) { Synaptical::Neuron.new }

    context 'with one neuron' do
      it { expect { add }.to change(layer, :size).by 1 }
    end
  end
end
