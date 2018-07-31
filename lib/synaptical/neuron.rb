# frozen_string_literal: true

module Synaptical
  # Representation of a neuron
  class Neuron
    CONNECTION_TYPES = %i[inputs projected gated].freeze

    Connections = Struct.new(:inputs, :projected, :gated)
    Connection = Struct.new(:type, :connection)
    Error = Struct.new(:responsibility, :projected, :gated)
    Trace = Struct.new(:elegibility, :extended, :influences)

    attr_reader :id, :connections, :error, :trace, :state, :old, :activation,
                :selfconnection, :squash, :neighbors, :bias
    # Creates an instance of a Neuron
    def initialize
      @id = self.class.uid
      @connections = Connections.new({}, {}, {})
      @error = Error.new(0.0, 0.0, 0.0)
      @trace = Trace.new({}, {}, {})

      @state = @old = @activation = 0.0
      @selfconnection = Synaptical::Connection.new(self, self, 0.0)
      @squash = Synaptical::Squash::Logistic
      @neighbors = {}
      @bias = rand * 0.2 - 0.1
    end

    # Activate the neuron
    # @param input = nil [Numeric] input value
    #
    # @return [Numeric] output value
    def activate(input = nil)
      # Is neuron in input layer
      unless input.nil?
        @activation = input
        @derivative = 0
        @bias = 0
        return activation
      end

      @old = @state

      # eq. 15.
      @state = selfconnection.gain * selfconnection.weight * state + bias

      connections.inputs.each do |_, neuron|
        @state += neuron.from.activation * neuron.weight * neuron.gain
      end

      # eq. 16.
      @activation = squash.call(@state)

      # f'(s)
      @derivative = squash.call(@state, true)

      # Update traces
      influences = []
      trace.extended.each_key do |id|
        neuron = @neighbors[id]

        influence = neuron.selfconnection.gater == self ? neuron.old : 0

        trace.influences[neuron.id].each do |incoming|
          influence +=
            trace.influences[neuron.id][incoming].weight *
            trace.influences[id][incoming].from.activation
        end

        influences[neuron.id] = influence
      end

      connections.inputs.each_value do |input_neuron|
        # elegibility trace - eq. 17
        trace.elegibility[input_neuron.id] =
          selfconnection.gain *
          selfconnection.weight *
          trace.elegibility[input_neuron.id] +
          input_neuron.gain *
          input_neuron.from.activation

        trace.extended.each do |id, xtrace|
          neuron = neighbors[id]
          influence = influences[neuron.id]

          xtrace[input_neuron.id] =
            neuron.selfconnection.gain *
            neuron.selfconnection.weight *
            xtrace[input_neuron.id] +
            @derivative *
            trace.elegibility[input_neuron.id] *
            influence
        end
      end

      # Update gated connection's gains
      connections.gated.each { |conn| conn.gain = @activation }

      @activation
    end

    # Back propagate the error
    # @param rate [Float] Learning rate
    # @param target = nil [Numeric] Target value
    def propagate(rate = 0.1, target = nil)
      error = 0.0

      # Is neuron in output layer
      if !target.nil?
        # Eq. 10.
        @error.responsibility = @error.projected = target - @activation
      else
        # The rest of the neuron compute their error responsibilities by back-
        # propagation
        connections.projected.each_value do |connection|
          neuron = connection.to

          # Eq. 21.
          error +=
            neuron.error.responsibility * connection.gain * connection.weight
        end

        # Projected error responsibility
        @error.projected = @derivative * error

        error = 0.0
        # Error responsibilities from all the connections gated by this neuron
        trace.extended.each do |id, _|
          neuron = @neighbors[id] # gated neuron
          # If gated neuron's selfconnection is gated by this neuron
          influence = neuron.selfconnection.gater == self ? neuron.old : 0.0

          # Index runs over all th econnections to the gated neuron that are
          # gated by this neuron
          trace.influences[id].each do |input, infl|
            # Captures the effect that the input connection of this neuron have,
            # on a neuron which its input/s is/are gated by this neuron
            influence +=
              infl.weight *
              trace.influences[neuron.id][input].from.activation
          end

          # Eq. 22.
          error += neuron.error.responsibility * influence
        end

        # Gated error responsibility
        @error.gated = @derivative * error

        # Error responsibility - Eq. 23.
        @error.responsibility = @error.projected + @error.gated
      end

      connections.inputs.each_value do |input_neuron|
        # Eq. 24
        gradient = @error.projected * trace.elegibility[input_neuron.id]
        trace.extended.each do |id, _|
          neuron = neighbors[id]
          gradient += neuron.error.responsibility *
            trace.extended[neuron.id][input_neuron.id]
        end

        # Adjust weights - aka. learn
        input_neuron.weight += rate * gradient
      end

      # Adjust bias
      @bias += rate * @error.responsibility
    end

    # [project description]
    # @param neuron [Synaptical::Neuron] Other neuron
    # @param weight = nil [Float] Weight
    #
    # @return [Synaptical::Connection] Connection
    def project(neuron, weight = nil)
      if neuron == self
        selfconnection.weight = 1
        return selfconnection
      end

      # Check if connection already exists
      connected = connected(neuron)
      if connected && connected.type == :projected
        # Update connection
        connected.connection.weight = weight unless weight.nil?
        return connected.connection
      else
        connection = ::Synaptical::Connection.new(self, neuron, weight)
      end

      # Reference all te connections and traces
      connections.projected[connection.id] = connection
      neighbors[neuron.id] = neuron
      neuron.connections.inputs[connection.id] = connection
      neuron.trace.elegibility[connection.id] = 0

      neuron.trace.extended.each do |_id, trace|
        trace[connection.id] = 0
      end

      connection
    end

    # Add connection to gated list
    # @param connection [Synaptical::Connection] Connection
    def gate(connection)
      connections.gated[connection.id] = connection

      neuron = connection.to
      unless trace.extended.key?(neuron.id)
        # Extended trace
        neighbors[neuron.id] = neuron
        xtrace = trace.extended[neuron.id] = {}
        connection.inputs.each_value do |input|
          xtrace[input.id] = 0
        end
      end

      # Keep track
      if trace.influences.key?(neuron.id)
        trace.influences[neuron.id] << connection
      else
        trace.influences[neuron.id] = [connection]
      end

      # Set gater
      connection.gater = self
    end

    # Returns wheter the neuron is self connected
    #
    # @return [Boolean] true if self connected, false otherwise
    def selfconnected?
      !selfconnection.weight.zero?
    end

    # Returns whether the neuron is connected to another neuron
    # @param neuron [Synaptical::Neuron] Other neuron
    #
    # @return [Boolean, Hash] Connection type if connected to other neuron,
    #                         false otherwise
    def connected(neuron)
      result = Connection.new

      if self == neuron
        return nil unless selfconnected?
        result.type = :selfconnection
        result.connection = selfconnection
        return result
      end

      CONNECTION_TYPES
        .map { |ct| connections.send(ct).values }
        .flatten
        .each do |connection|
          next unless connection.to == neuron || connection.from == neuron
          result.type = type
          result.connection = type
          return result
        end

      nil
    end

    # Clear the context of the neuron, but keeps connections
    def clear
      trace.elegibility.transform_values { |_| 0 }
      trace.extended.each_value do |ext|
        ext.transform_values { |_| 0 }
      end

      error.responsibility = error.projected = error.gated = 0
    end

    # Clears traces and randomizes connections
    def reset
      clear
      CONNECTION_TYPES.map { |ct| connections.send(ct) }.each do |conn_group|
        conn_group.each { |conn| conn.weight = rand * 0.2 - 0.1 }
      end

      @bias = rand * 0.2 - 0.1
      @old = @state = @activation = 0
    end

    # Hard codes the behavior of the neuron into an optimized function
    # @param optimized [Hash] [description]
    # @param layer [type] [description]
    #
    # @return [type] [description]
    def optimize(_optimized, _layer)
      raise 'TODO'
    end

    class << self
      attr_reader :neurons
      # Returns the next id in the sequence
      #
      # @return [type] [description]
      def uid
        @neurons += 1
      end

      def quantity
        { neurons: neurons, connections: Connection.connections }
      end
    end

    @neurons = 0
  end
end
