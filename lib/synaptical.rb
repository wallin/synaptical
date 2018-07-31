# frozen_string_literal: true

%w[
  synaptical/squash/logistic
  synaptical/connection
  synaptical/layer
  synaptical/layer_connection
  synaptical/network
  synaptical/neuron
  synaptical/version
].each(&method(:require))

module Synaptical; end
