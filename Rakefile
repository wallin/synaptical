# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'synaptical'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

def create_network
  input_layer = Synaptical::Layer.new(2)
  hidden_layer = Synaptical::Layer.new(3)
  output_layer = Synaptical::Layer.new(1)

  input_layer.project(hidden_layer)
  hidden_layer.project(output_layer)

  Synaptical::Network.new(
    input: input_layer, hidden: [hidden_layer], output: output_layer
  )
end

def train(network)
  learning_rate = 0.3

  network.activate([0, 0])
  network.propagate(learning_rate, [0])

  network.activate([0, 1])
  network.propagate(learning_rate, [1])

  network.activate([1, 0])
  network.propagate(learning_rate, [1])

  network.activate([1, 1])
  network.propagate(learning_rate, [0])
end

def activate(network)
  network.activate([rand(2), rand(2)])
end

task :benchmark do
  require 'benchmark/ips'
  require 'benchmark/memory'

  network = create_network

  train = lambda do |x|
    x.report('training') { train(network) }
    x.compare!
  end

  activate = lambda do |x|
    x.report('activate') { activate(network) }
    x.compare!
  end

  Benchmark.ips(&train)
  Benchmark.memory(&train)
  Benchmark.ips(&activate)
  Benchmark.memory(&activate)
end

namespace :profile do
  require 'hotch'
  require 'hotch/memory'

  task :training do
    network = create_network
    Hotch() do
      10_000.times do
        train(network)
      end
    end

    Hotch.memory do
      10_000.times do
        train(network)
      end
    end
  end

  task :activate do
    network = create_network
    10_000.times { train(network) }
    Hotch() do
      10_000.times { activate(network) }
    end

    Hotch.memory do
      10_000.times { activate(network) }
    end
  end
end
