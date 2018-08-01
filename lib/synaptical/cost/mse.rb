# frozen_string_literal: true

module Synaptical
  module Cost
    # Mean square error
    module Mse
      class << self
        # Calculates mean square error for a series of results
        # @param target [Array<Numeric>] Desired values
        # @param output [Array<Numeric>] Output values from prediction
        #
        # @return [Float] Combined mean square error
        def call(target, output)
          mse = 0.0
          target.zip(output).each { |t, o| mse += (t - o)**2 }
          mse.fdiv(output.size)
        end
      end
    end
  end
end
