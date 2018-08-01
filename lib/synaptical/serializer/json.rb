# frozen_string_literal: true

module Synaptical
  module Serializer
    module JSON
      class << self
        # Generates a serialized Hash from a network
        # @param network [Synaptical::Network] Network to serialize
        #
        # @return [Hash] Serialized network as hash
        def as_json(network)
          unless network.is_a?(Synaptical::Network)
            raise ArgumentError, 'Only Networks can be serialized'
          end

          list = network.neurons
          neurons = []
          connections = []

          ids = {}
          list.each_with_index do |nr, i|
            neuron = nr[:neuron]
            ids[neuron.id] = i
            copy = {
              trace: { elegibility: {}, extended: {} },
              state: neuron.state,
              old: neuron.old,
              activation: neuron.activation,
              bias: neuron.bias,
              layer: nr[:layer],
              squash: 'LOGISTIC'
            }

            neurons << copy
          end

          list.each do |nr|
            neuron = nr[:neuron]

            neuron.connections.projected.each do |_id, conn|
              connections << {
                from: ids[conn.from.id],
                to: ids[conn.to.id],
                weight: conn.weight,
                gater: conn.gater ? ids[conn.gater.id] : nil
              }
            end

            next unless neuron.selfconnected?

            connections << {
              from: ids[neuron.id],
              to: ids[neuron.id],
              weight: neuron.selfconnection.weight,
              gater: neuron.selfconnection.gater ? ids[neuron.selfconnection.gater.id] : nil
            }
          end

          { neurons: neurons, connections: connections }
        end

        # Produces a serialized JSON string
        # @param network [Synaptical::Network] network to serialize
        #
        # @return [String] Serialized network as JSON
        def dump(network)
          require 'json'
          JSON.dump(as_json(network))
        end

        # Loads a network from JSON
        # @param json [String] JSON string
        #
        # @return [Synaptical::Network] De-serialized network
        def load(_json)
          raise 'TODO'
        end
      end
    end
  end
end
