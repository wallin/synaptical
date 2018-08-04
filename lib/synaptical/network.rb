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

      Synaptical::Serializer::JSON.as_json(self)
    end

    def to_dot
      raise 'TODO'
    end

    class << self
      # Loads a network from serialized format
      # @param json [Hash] Hash containing network representation
      #
      # @return [Synaptical::Network] De-serialized network
      def from_json(json)
        Synaptical::Serializer::JSON.from_json(json)
      end
    end
  end
end
