class Bicycle
  attr_reader :size, :parts

  def initialize(args = {})
    @size = args[:size]
    @parts = args[:parts]
  end

  def spares
    parts.spares
  end
end

class Parts
  attr_reader :parts

  def initialize(parts)
    @parts = parts
  end

  def spares
    parts.select { |part| part.needs_spare }
  end
end

class Part
  attr_reader :name, :description, :needs_spare

  def initialize(args)
    @name = args[:name]
    @description = args[:description]
    @needs_spare = args.fetch(:needs_sparem, true)
  end
end

chain = Part.new(
  name: 'chain', description: '10-spaeed'
)

road_tire = Part.new(
  name: 'tire_size', description: '23'
)

tape = Part.new(
  name: 'tape_color', description: 'red'
)

mountain_tire = Part.new(
  name: 'tire_size', description: '2.1'
)

rear_shock = Part.new(
  name: 'rear_shock', description: 'Fox'
)

front_shock = Part.new(
  name: 'front_shock', description: 'Manitou', needs_spare: false
)

road_bike_part = Parts.new([chain, road_tire, tape])

class Parts
  def size
    parts.size
  end
end

require 'forwardable'
class Parts
  extend Forwardable
  def_delegators :@parts, :size, :each

  iclude Enumerable

  def initialize(parts)
    @parts = parts
  end

  def spares
    select { |part| part.needs_spare }
  end
end
