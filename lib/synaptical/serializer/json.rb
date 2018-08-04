# frozen_string_literal: true

module Synaptical
  module Serializer
    # Serialize a network as JSON
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
              'trace' => { elegibility: {}, extended: {} },
              'state' => neuron.state,
              'old' => neuron.old,
              'activation' => neuron.activation,
              'bias' => neuron.bias,
              'layer' => nr[:layer],
              'squash' => neuron.squash.name
            }

            neurons << copy
          end

          list.each do |nr|
            neuron = nr[:neuron]

            neuron.connections.projected.each do |_id, conn|
              connections << {
                'from' => ids[conn.from.id],
                'to' => ids[conn.to.id],
                'weight' => conn.weight,
                'gater' => conn.gater ? ids[conn.gater.id] : nil
              }
            end

            next unless neuron.selfconnected?

            connections << {
              'from' => ids[neuron.id],
              'to' => ids[neuron.id],
              'weight' => neuron.selfconnection.weight,
              'gater' => neuron.selfconnection.gater ? ids[neuron.selfconnection.gater.id] : nil
            }
          end

          { 'neurons' => neurons, 'connections' => connections }
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
        def load(json)
          require 'json'
          from_json(JSON.parse(json))
        end

        # Instantiates a network from a Hash
        # @param json [Hash] Hash with serialized network
        #
        # @return [Synaptical::Network] De-serialized network
        def from_json(json)
          layers = { hidden: [] }

          attributes = %w[state old activation bias]
          neurons = json['neurons'].map do |config|
            Synaptical::Neuron.new.tap do |neuron|
              attributes.each { |a| neuron.send("#{a}=", config[a]) }
              neuron.squash = const_get(config['squash'])
              layer_id = config['layer']
              layer = case layer_id
                      when 'input', 'output'
                        layers[layer_id.to_sym] ||= Synaptical::Layer.new(0)
                      else
                        layers[:hidden][layer_id] ||= Synaptical::Layer.new(0)
                      end

              layer.add(neuron)
            end
          end

          json['connections'].each do |config|
            from, to = neurons.values_at(config['from'], config['to'])
            weight = config['weight']

            connection = from.project(to, weight)
            gater = neurons[config['gater']] if config['gater']
            gater&.gate(connection)
          end

          Synaptical::Network.new(layers)
        end
      end
    end
  end
end
