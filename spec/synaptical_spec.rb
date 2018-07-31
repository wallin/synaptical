# frozen_string_literal: true

RSpec.describe Synaptical do
  TrainingData = Struct.new(:input, :output)

  let(:learning_rate) { 0.3 }
  let(:network) do
    Synaptical::Network.new(
      input: input_layer, hidden: [hidden_layer], output: output_layer
    )
  end

  before do
    # Connect layers
    input_layer.project(hidden_layer)
    hidden_layer.project(output_layer)
  end

  context 'when trained as gate' do
    let(:input_layer) { Synaptical::Layer.new(2) }
    let(:hidden_layer) { Synaptical::Layer.new(3) }
    let(:output_layer) { Synaptical::Layer.new(1) }

    shared_examples_for 'a gate' do
      before do
        2000.times do
          network.activate(row1.input)
          network.propagate(learning_rate, [row1.output])

          network.activate(row2.input)
          network.propagate(learning_rate, [row2.output])

          network.activate(row3.input)
          network.propagate(learning_rate, [row3.output])

          network.activate(row4.input)
          network.propagate(learning_rate, [row4.output])
        end
      end

      it { expect(network.activate(row1.input)[0]).to be_within(0.01).of(row1.output) }
      it { expect(network.activate(row2.input)[0]).to be_within(0.01).of(row2.output) }
      it { expect(network.activate(row3.input)[0]).to be_within(0.01).of(row3.output) }
      it { expect(network.activate(row4.input)[0]).to be_within(0.01).of(row4.output) }
    end

    context 'with XOR' do
      let(:row1) { TrainingData.new([0, 0], 0) }
      let(:row2) { TrainingData.new([0, 1], 1) }
      let(:row3) { TrainingData.new([1, 0], 1) }
      let(:row4) { TrainingData.new([1, 1], 0) }

      it_behaves_like 'a gate'
    end

    context 'with AND' do
      let(:row1) { TrainingData.new([0, 0], 0) }
      let(:row2) { TrainingData.new([0, 1], 0) }
      let(:row3) { TrainingData.new([1, 0], 0) }
      let(:row4) { TrainingData.new([1, 1], 1) }

      it_behaves_like 'a gate'
    end

    context 'with OR' do
      let(:row1) { TrainingData.new([0, 0], 0) }
      let(:row2) { TrainingData.new([0, 1], 1) }
      let(:row3) { TrainingData.new([1, 0], 1) }
      let(:row4) { TrainingData.new([1, 1], 1) }

      it_behaves_like 'a gate'
    end
  end
end
