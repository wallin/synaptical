# frozen_string_literal: true

RSpec.describe Synaptical::Architect::Perceptron do
  describe '.new' do
    subject(:call) { described_class.new(*args) }

    context 'with less than 3 arguments' do
      let(:args) { [1, 2] }

      it { expect { call }.to raise_error(ArgumentError) }
    end

    context 'with [2, 3, 1]' do
      let(:args) { [2, 3, 1] }

      it { is_expected.to have_attributes(inputs: 2, outputs: 1) }

      describe 'neurons.size' do
        subject { call.neurons.size }

        it { is_expected.to eq 6 }
      end
    end
  end
end
