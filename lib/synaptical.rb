# frozen_string_literal: true

%w[
  synaptical/squash/logistic
  synaptical/squash/tanh
  synaptical/connection
  synaptical/layer
  synaptical/layer_connection
  synaptical/network
  synaptical/neuron
  synaptical/trainer
  synaptical/version
  synaptical/architect/perceptron
  synaptical/cost/mse
  synaptical/serializer/json
].each(&method(:require))

module Synaptical; end
