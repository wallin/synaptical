# frozen_string_literal: true

module Synaptical
  # Squashing functions
  module Squash
    # Logistic function
    module Logistic
      class << self
        # Apply logistic function for x_val
        # @param x_val [Numeric] X value
        # @param derivate = false [Boolean] Indicate if derivative should be returned
        #
        # @return [Float] Y value
        def call(x_val, derivate = false)
          fx = 1.fdiv(1 + ::Math.exp(-x_val))
          derivate ? (fx * (1 - fx)) : fx
        end
      end
    end
  end
end
