# Synaptical

Synaptical is a Ruby port of [synaptic.js](https://github.com/cazala/synaptic)

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wallin/synaptical.
