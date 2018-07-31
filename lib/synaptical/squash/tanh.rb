# frozen_string_literal: true

module Synaptical
  # Squashing functions
  module Squash
    # Hyperbolic tangens function
    module Tanh
      class << self
        # Apply hyperbolic tangens function for x_val
        # @param x_val [Numeric] X value
        #
        # @return [Float] Y value
        def call(x_val)
          ::Math.tanh(x_val)
        end

        # Calculate derivate of value
        # @param x_val [Numeric] value
        #
        # @return [Float] Derivate value
        def derivate(x_val)
          1.0 - x_val**2
        end
      end
    end
  end
end
