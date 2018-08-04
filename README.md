# Synaptical

Synaptical is a Ruby port of [synaptic.js](https://github.com/cazala/synaptic)

**NOTE: This is work in progress and some componets of synaptic.js are still missing**

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'synaptical'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install synaptical

## Usage

Usage is identical to [synaptic.js](https://github.com/cazala/synaptic).

Example network trained to solve a XOR gate:

```ruby
input_layer = Synaptical::Layer.new(2)
hidden_layer = Synaptical::Layer.new(3)
output_layer = Synaptical::Layer.new(1)

input_layer.project(hidden_layer)
hidden_layer.project(output_layer)

network = Synaptical::Network.new(
  input: input_layer,
  hidden: [hidden_layer],
  output: output_layer
)

learning_rate = 0.3

10_000.times do
  network.activate([0, 0])
  network.propagate(learning_rate, [0])

  network.activate([0, 1])
  network.propagate(learning_rate, [1])

  network.activate([1, 0])
  network.propagate(learning_rate, [1])

  network.activate([1, 1])
  network.propagate(learning_rate, [0])
end

network.activate([0, 0])
  # => [0.00020797967275049887]
network.activate([0, 1])
  # => [0.9991989909682668]
network.activate([1, 0])
  # => [0.9992882541963027]
network.activate([1, 1])
  # => [0.0011764423621223423]
```

or create the network with the Perceptron architect and the Trainer:

```ruby

network = Synaptical::Architect::Perceptron.new(2, 3, 1)
trainer = Synaptical::Trainer.new(network)
trainer.train([
  { input: [0, 0], output: [0] },
  { input: [0, 1], output: [1] },
  { input: [1, 0], output: [1] },
  { input: [1, 1], output: [0] }
])

network.activate([0, 0])
  # => [0.04564830744951351]
network.activate([0, 1])
  # => [0.9590894310802323]
network.activate([1, 0])
  # => [0.9112358846059638]
network.activate([1, 1])
  # => [0.0832359653922508]

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wallin/synaptical.
