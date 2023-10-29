class Bicycle
  attr_reader :size, :chain, :tire_size

  def initialize(args = {})
    @size = args[:size]
    @chain = args[:chain]
    @tire_size = args[:tire_size]
  end

  def spares
    {
      tire_size: tire_size,
      chain: chain
    }
  end

  def default_chain
    '10-speed'
  end

  def default_tire_size
    raise NotImplementedError
  end
end

class RoadBike < Bicycle
  attr_reader :tape_color

  def initialize(args)
    @tape_color = args[:tape_color]
    super(args)
  end

  def spares
    super.merge({ tape_color: tape_color })
  end

  def default_tire_size
    '23'
  end
end

class MountainBike < Bicycle
  attr_reader :front_shock, :rear_shock

  def initialize(args)
    @front_shock = args[:front_shock]
    @rear_shock = args[:rear_shock]
    super(args)
  end

  def spares
    super.merge({ rear_shock: rear_shock })
  end

  def default_tire_size
    '2.1'
  end
end

class RecumbentBike < Bicycle
  attr_reader :flag

  def initialize(args)
    @flag = args[:flag] # superを送信するのを忘れた
  end

  def spares
    super.merge({ flag: flag })
  end

  def default_chain
    '9-speed'
  end

  def default_tire_size
    '28'
  end
end

bent = RecumbentBike.new(flag: 'tall and orange')
bent.spares
# ->{
#     tire_size: nil,  <- 初期化されてない
#     chain: nil,
#     flag: 'tall and orange'
#   }

class Bicycle
  def initialize(args = {})
    @size = args[:size]
    @chain = args[:chain] || default_chain
    @tire_size = args[:tire_size] || default_tire_size

    post_initialize(args) # Bicycleでは送信と
  end

  def post_initialize(_args) # 実装の両方を行う
    nil
  end

  # ...
end

class RoadBike < Bicycle
  def post_initialize(args) # RoadBikeは任意でオーバーライドできる
    @tape_color = args[:tape_color]
  end
  # ...
end

class Bicycle
  # ...

  def spares
    {
      tire_size: tire_size,
      chain: chain
    }.merge(local_spares)
  end

  # サブクラスがオーバーライドするためのフック
  def local_spares
    {}
  end
end

class RoadBike < Bicycle
  # ...
  def local_spares
    {
      tape_color: tape_color
    }
  end
end
