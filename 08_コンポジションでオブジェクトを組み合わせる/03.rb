module PartsFactory
  def self.building(config,
                    part_class = Part,
                    parts_class = Parts)

    parts_class.new(
      config.collect do |part_config|
        part_class.new(
          name: part_config[0],
          description: part_config[1],
          needs_spare: part_config.fetch(2, true)
        )
      end
    )
  end
end

road_config = [
  %w[chain 10-speed],
  %w[tire_size 23],
  %w[tape_color red]
]

mountain_config = [
  ['chain', '10-speed'],
  ['tire_size', '2.1'],
  ['frint_shock', 'Manitou', false],
  ['rear_shock', 'Fox']
]

road_parts = PartsFactory.new(road_config)
mountain_parts = PartsFactory.new(mountain_config)

class Part
  attr_reader :name, :description, :needs_spare

  def initialize(args)
    @name = args[:name]
    @description = args[:description]
    @needs_spare = args.fetch(:needs_spare, true)
  end
end

require 'ostruct'

module PartsFactory
  def self.build(config, parts_class = Parts)
    parts_class.new(
      config.collect | part_config |
        create_part(part_config)
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
