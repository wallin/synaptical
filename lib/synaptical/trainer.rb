# frozen_string_literal: true

module Synaptical
  class Trainer
    attr_accessor :network, :rate, :iterations, :error, :cost, :cross_validate

    Result = Struct.new(:error, :iterations, :time)

    # Creates a new network trainer
    # @param network [Synaptical::Network] Network to train
    # @param rate: 0.2 [Float, Proc] Learning rate
    # @param iterations: 100_000 [Integer] Training iterations
    # @param error: 0.005 [Float] Max error
    # @param cost: nil [type] [description]
    # @param cross_validate: nil [type] [description]
    def initialize(network, rate: 0.2, iterations: 100_000, error: 0.005, cost: Synaptical::Cost::Mse, cross_validate: false)
      @network = network
      @rate = rate
      @iterations = iterations
      @error = error
      @cost = cost
      @cross_validate = cross_validate
    end

    def train(set, options = nil)
      error = 1.0
      stop = false
      iterations = bucket_size = 0
      current_rate = rate
      cross_validate = false
      cost = self.cost
      start = Time.now

      bucket_size = iterations.fdiv(rate.size).floor if rate.is_a?(Array)

      if cross_validate
        num_train = ((1 - cross_validate.test_size) * set.size).ceil
        train_set = set[0..num_train]
        test_set = set[num_train..-1]
      end

      last_error = 0.0

      while !stop && iterations < self.iterations && error > self.error
        break if cross_validate && error <= self.cross_validate

        current_set_size = set.size
        error = 0.0
        iterations += 1

        if bucket_size.positive?
          current_bucket = iterations.fdiv(bucket_size).floor
          current_rate = rate[current_bucket] || current_rate
        end

        current_rate = rate.call(iterations, last_error) if rate.is_a?(Proc)

        if cross_validate
          train_set(train_set, current_rate, cost)
          error += test(test_set).error
          current_set_size = 1
        else
          error += train_set(set, current_rate, cost)
        end

        error /= current_set_size.to_f
        last_error = error

        raise 'TODO' if options
      end

      Result.new(error, iterations, Time.now - start)
    end

    def train_set(set, current_rate, cost_function)
      set.reduce(0.0) do |sum, item|
        input = item[:input]
        target = item[:output]
        output = network.activate(input)
        network.propagate(current_rate, target)
        sum + cost_function.call(target, output)
      end
    end

    def test(_set)
      raise 'TODO'
    end
  end
end
