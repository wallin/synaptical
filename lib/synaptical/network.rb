# frozen_string_literal: true

module Synaptical
  # Representation of a network
  class Network
    Layers = Struct.new(:input, :hidden, :output)

    attr_reader :optimized, :layers

    def initialize(input:, hidden:, output:)
      @layers = Layers.new(input, hidden, output)
      @optimized = false
    end

    # Feed-forward activation of all the layers to produce an output
    # @param input [Array<Numeric>] Input
    #
    # @return [Array<Numeric>] Output
    def activate(input)
      raise if optimized
      layers.input.activate(input)
      layers.hidden.each(&:activate)
      layers.output.activate
    end

    # Back-propagate the error through the network
    # @param rate [Float] Learning rate
    # @param target [Array<Numeric>] Target values
    def propagate(rate, target)
      raise if optimized
      layers.output.propagate(rate, target)
      layers.hidden.each { |layer| layer.propagate(rate) }
    end

    # Project output onto another layer or network
    # @param unit [Synaptical::Network, Synaptical::Layer] Object to project against
    # @param type [type] [description]
    # @param weights [type] [description]
    def project(unit, type, weights)
      raise if optimized
      case unit
      when Network
        layers.output.project(unit.layers.input, type, weights)
      when Layer
        layers.output.project(unit, type, weights)
      else
        raise ArgumentError, 'Invalid argument'
      end
    end

    def gate(connection, type)
      raise if optimized
      layers.output.gate(connection, type)
    end

    def clear
      restore
      ([layers.input, layers.output] + layers.hidden).each(&:clear)
    end

    def reset
      restore
      ([layers.input, layers.output] + layers.hidden).each(&:reset)
    end

    def optimize
      raise
    end

    def restore
      raise if optimized
    end

    # Return all neurons in all layers
    #
    # @return [Array<Hash>] A list of neurons and which layer they belong to
    def neurons
      layers.input.neurons.map { |n| { neuron: n, layer: 'input' } } +
        layers.hidden
              .flat_map(&:neurons)
              .each_with_index
              .map { |n, i| { neuron: n, layer: i } } +
        layers.output.neurons.map { |n| { neuron: n, layer: 'output' } }
    end

    # Return number of inputs
    #
    # @return [Integer] Number of inputs
    def inputs
      layers.input.size
    end

    # Return number of outputs
    #
    # @return [Integer] Number of outputs
    def outputs
      layers.output.size
    end

    def set
      raise 'TODO'
    end

    def set_optimize
      raise 'TODO'
    end

    # Export the network as JSON
    #
    # @return [Hash] Hash ready for JSON serialization
    def to_json
      restore

      list = neurons
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

    def to_dot
      raise 'TODO'
    end

    def from_json
      raise 'TODO'
    end
  end
end
