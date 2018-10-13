# frozen_string_literal: true

module Synaptical
  # Representation of a connection between layers
  class LayerConnection
    attr_reader :id, :from, :to, :selfconnection, :type, :connections, :list,
                :size, :gatedfrom
    def initialize(from, to, type, weights)
      @id = self.class.uid
      @from = from
      @to = to
      @selfconnection = to == from
      @type = type
      @connections = {}
      @list = []
      @size = 0
      @gatedfrom = []

      init_type

      connect!(weights)
    end

    # Initialize connection type if not provided
    def init_type
      return unless type.nil?

      @type = if from == to
                Synaptical::Layer::CONNECTION_TYPE[:ONE_TO_ONE]
              else
                Synaptical::Layer::CONNECTION_TYPE[:ALL_TO_ALL]
              end
    end

    def connect!(weights)
      if type == Synaptical::Layer::CONNECTION_TYPE[:ALL_TO_ALL] ||
         type == Synaptical::Layer::CONNECTION_TYPE[:ALL_TO_ELSE]
        from.list.each do |from|
          to.list.each do |to|
            if type == Synaptical::Layer::CONNECTION_TYPE[:ALL_TO_ELSE] &&
               from == to
              next
            end

            connection = from.project(to, weights)
            @connections[connection.id] = connection
            list.push(connection)
            @size = list.size
          end
        end
      elsif type == Synaptical::Layer::CONNECTION_TYPE[:ONE_TO_ONE]
        from.list.each_with_index do |from, idx|
          to = to.list[idx]
          connection = from.project(to, weights)

          @connections[connection.id] = connection
          list.push(connection)
          @size = list.size
        end
      end

      from.connected_to << self
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
