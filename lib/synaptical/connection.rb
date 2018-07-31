# frozen_string_literal: true

module Synaptical
  # Representation of a connection between two neurons
  class Connection
    attr_reader :id, :from, :to, :gain, :gater
    attr_accessor :weight

    # Creates a connection between two neurons
    # @param from [Synaptical::Neuron] First neuron
    # @param to [Synaptical::Neuron] Second neuron
    # @param weight = nil [Float] connection weight
    def initialize(from, to, weight = nil)
      @id = self.class.uid
      @from = from
      @to = to
      @weight = weight.nil? ? (rand * 0.2 - 0.1) : weight
      @gain = 1.0
    end

    class << self
      attr_reader :connections

      def uid
        @connections += 1
      end
    end

    @connections = 0
  end
end
