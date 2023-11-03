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

require 'forwardable'
class Parts
  extend Forwardable
  def_delegators :@parts, :size, :each
  include Enumerable

  def initialize(parts)
    @parts = parts
  end

  # selectはEnumerableのメソッドで、内部的にはeachを使う。
  # eachは@partsに委譲されているので、@partsに対して実行される
  def spares
    select { |part| part.needs_spare }
  end
end

require 'ostruct'
module PartsFactory
  def self.build(config, parts_class = Parts)
    parts_class.new(
      config.collect do |part_config|
        create_part(part_config)
      end
    )
  end

  def self.create_part(part_config)
    OpenStruct.new(
      name: part_config[0],
      description: part_config[1],
      needs_spare: part_config.fetch(2, true)
    )
  end
end

road_config = [
  %w[chain 10-speed],
  %w[tire_size 23],
  %w[tape_color red]
]

mountain_config = [
  ['chain', '10-spaeed'],
  ['tire_size', '2,1'],
  ['front_shock', 'Manitou', false],
  ['rear_shock', 'Fox']
]

recumbent_config = [
  ['chain', '9-speed'],
  ['tire_size', '28'],
  ['flag', 'tall and orange']
]

recumbent_bike = Bicycle.new(
  size: 'L',
  parts: PartsFactory.build(recumbent_config)
)

recumbent_bike.spares
