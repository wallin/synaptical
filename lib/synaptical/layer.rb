# frozen_string_literal: true

module Synaptical
  # Representation of a layer in a network
  class Layer
    CONNECTION_TYPE = {
      ALL_TO_ALL: 'ALL TO ALL',
      ONE_TO_ONE: 'ONE TO ONE',
      ALL_TO_ELSE: 'ALL TO ELSE'
    }.freeze

    GATE_TYPE = {
      INPUT: 'INPUT',
      OUTPUT: 'OUTPUT',
      ONE_TO_ONE: 'ONE TO ONE'
    }.freeze

    attr_reader :list, :connected_to, :size

    # Creates a new layer with a given size
    # @param size [Integer] Size of layer
    def initialize(size)
      @size = size
      @connected_to = []
      @list = Array.new(size).map { Synaptical::Neuron.new }
    end

    # Activates the neurons in the layer
    # @param input [Array<Numeric>] Array of inputs with same size as the layer
    #
    # @raise [ArgumentError] if input size mismatch layer size
    #
    # @return [Array<Numeric>] Array of output values with same size as the layer
    def activate(input = nil)
      if input.nil?
        list.map(&:activate)
      else
        raise ArgumentError unless input.size == size
        list.zip(input).map { |neuron, value| neuron.activate(value) }
      end
    end

    # Propagates the error on all the neurons of the layer
    # @param rate [Float] Learning rate
    # @param target = nil [Array<Numeric>] Target value
    #
    # @raise [ArgumentError] if target size mismatch layer size
    def propagate(rate, target = nil)
      if target.nil?
        list.each { |neuron| neuron.propagate(rate) }
      else
        raise ArgumentError unless target.size == size
        list.zip(target).each { |neuron, value| neuron.propagate(rate, value) }
      end
    end

    # Projects a connection from this layer to another one
    # @param layer [Synaptical::Layer, Synaptical::Network] Network/Layer to project to
    # @param type = nil [type] [description]
    # @param weight = nil [type] [description]
    #
    # @raise [ArgumentError] if layer is already connected
    def project(layer, type = nil, weight = nil)
      layer = layer.layers.input if layer.is_a?(Network)

      raise ArgumentError if connected(layer)

      LayerConnection.new(self, layer, type, weight)
    end

    # Gates a connection between two layers
    # @param conntection [LayerConnection] Layer connection
    # @param type [type] [description]
    def gate(_connection, _type)
      raise 'TODO'
    end

    # Returns wether the whole layer is self-connected or not
    #
    # @return [Boolean] true if self-connected, false otherwise
    def selfconnected?
      list.all?(&:selfconnected?)
    end

    # Returns whether the layer is connected to another layer
    # @param layer [Synaptical::Layer] Other layer
    #
    # @return [Boolean] true if connected to the other layer, false otherwise
    def connected(layer)
      # Check if ALL to ALL connection
      connections = 0
      list.each do |from|
        layer.list.each do |to|
          connected = from.connected(to)
          connections += 1 if connected&.type == :projected
        end
      end

      return Layer::CONNECTION_TYPE[:ALL_TO_ALL] if connections == size * layer.size

      # Check if ONE to ONE connection
      connections = 0
      list.each_with_index do |from, idx|
        to = layer.list[idx]
        connected = from.connected(to)
        connections += 1 if connected&.type == :projected
      end

      return Layer::CONNECTION_TYPE[:ONE_TO_ONE] if connections == size

      false
    end

    # Clears all the neurons in the layer
    def clear
      list.each(&:clear)
    end

    # Resets all the neurons in the layer
    def reset
      list.each(&:reset)
    end

    # Returns all the neurons in the layer
    #
    # @return [Array<Synaptical::Neuron>] List of neurons in the layer
    alias neurons list

    # Adds a neuron to the layer
    # @param neuron [Synaptical::Neuron] The new neuron
    def add(neuron = Neuron.new)
      list << neuron
      @size += 1
    end

    # Configure layer options
    #
    # @return [Hash] Hash with options options
    def set(_options)
      raise 'TODO'
    end
  end
end
