# frozen_string_literal: true

module Synaptical
  # Squashing functions
  module Squash
    # Logistic function
    module Logistic
      class << self
        # Apply logistic function for x_val
        # @param x_val [Numeric] X value
        #
        # @return [Float] Y value
        def call(x_val)
          1.0 / (1.0 + ::Math.exp(-x_val))
        end

        # Calculate derivate of value
        # @param x_val [Numeric] value
        #
        # @return [Float] Derivate value
        def derivate(x_val)
          (x_val * (1 - x_val))
        end
      end
    end
  end
end
