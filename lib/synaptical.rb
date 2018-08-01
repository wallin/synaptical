# frozen_string_literal: true

%w[
  synaptical/squash/logistic
  synaptical/squash/tanh
  synaptical/connection
  synaptical/layer
  synaptical/layer_connection
  synaptical/network
  synaptical/neuron
  synaptical/version
  synaptical/architect/perceptron
  synaptical/serializer/json
].each(&method(:require))

module Synaptical; end
