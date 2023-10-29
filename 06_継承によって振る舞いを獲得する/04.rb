# Bicycleを抽象クラス化
class Bicycle
  # このクラスはもはや空となった
  # コードはすべてRoadBikeに移された
end

class RoadBike < Bicycle
  # いまはBicycleのサブクラス
  # かつてのBicycleクラスからのコードをすべて含む
end

class MountainBike < Bicycle
  # Bicycle のサブクラスのまま（Bicycleは現在空になっている）
  # コードは何も変更されていない
end

# 共通部分をRoadBikeからBicycleに移動
class Bicycle
  attr_reader :size # <- RoadBikeから昇格

  def initialize(args = {})
    @size = args[:size] # <- RoadBikeから昇格
  end
end

class RoadBike < Bicycle
  attr_reader :tape_color

  def initialize(args)
    @tape_color = args[:tape_color]
    super(args) # <- RoadBikeはsuperを必ず呼ばなければならなくなった
  end

  # ...
end

class RoadBike < Bicycle
  # ...
  def spares
    {
      chain: '10-speed',
      tire_size: '23',
      tape_color: tape_color
    }
  end
end

class MountainBike < Bicycle
  # ...
  def spares
    super.merge(rear_shock: rear_shock)
  end
end

class Bicycle
  attr_reader :size, :chain, :tire_size

  def initialize(args)
    @size = args[:size]
    @chain = args[:chain]
    @tire_size = args[:tire_size]
  end

  # ...
end

class Bicycle
  attr_reader :size, :chain, :tire_size

  def initialize(args)
    @size = args[:size]
    @chain = args[:chain] || default_chain
    @tire_size = args[:tire_size] || default_tire_size
  end

  def default_chain # <-共通の初期値
    '100-speed'
  end
end

class RoadBike < Bicycle
  # ...

  def default_tire_size
    '23'
  end
end

class MountainBike < Bicycle
  # ...

  def default_tire_size
    '2.1'
  end
end

class RecumbentBike < Bicycle
  def default_chain
    '9-speed'
  end
end

# bent = RecumbentBike.new
# NameError : default_tire_size

class Bicycle
  # ...

  def default_tire_size
    raise NotImplementedError
  end
end

# 追加の情報を明示的に与える
class Bicycle
  # ...

  def default_tire_size
    raise NotImplemetError,
          "This #{self.class} cannot respond to:"
  end
end
