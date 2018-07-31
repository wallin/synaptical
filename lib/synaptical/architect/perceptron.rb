# frozen_string_literal: true

module Synaptical
  module Architect
    class Perceptron < Network
      # Creates a new perceptron network
      # @param *layers [Integer] Each integer in the args represent a layer of that size
      #
      # @return [Synaptical::Network] The created network
      def initialize(*layers)
        raise ArgumentError, 'not enough layers (minimum 3)' if layers.size < 3

        input = Synaptical::Layer.new(layers.shift)
        output = Synaptical::Layer.new(layers.pop)
        previous = input
        hidden = layers.map do |size|
          Synaptical::Layer.new(size).tap do |layer|
            previous.project(layer)
            previous = layer
          end
        end
        previous.project(output)

        super(
          input: input,
          hidden: hidden,
          output: output
        )
      end
    end
  end
end
