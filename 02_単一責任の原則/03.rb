# インスタンス変数は常にアクセサメソッドで包み、直接参照しないようにしましょう。

class Gear
  def initialize(chainring, cog)
    @chainring = chainring
    @cog = cog
  end

  def ratio
    @chainring / @cog.to_f # <--　破滅への道
  end
end

# 変数はそれらを定義しているクラスからでさえも隠蔽しましょう。
class Gear
  attr_reader :chainring, :cog

  def initialize(chainring, cog)
    @chainring = chainring
    @cog = cog
  end

  def ratio
    chainring / cog.to_f
  end
end

# データ構造の隠蔽

class ObscuringReferences
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def diameters
    # 0はリム、１はタイヤ
    data.collect do |cell|
      cell[0] + (cell[1] * 2)
    end
  end
end

@data = [[622, 20], [622, 23], [559, 30], [559, 40]]

class RevealingReferences
  attr_reader :wheels

  def initialize(data)
    @wheels = wheelify(data)
  end

  def diameters
    wheels.collect do |wheel|
      wheel.rim + (wheel.tire * 2)
    end
  end
  # これで誰でもwheelにrim/tireを送れる

  Wheel = Struct.new(:rim, :tire)
  def wheelify(data)
    data.collect do |cell|
      Wheel.new(cell[0], cell[1])
    end
  end
end

class RevealingReferences
  # メソッドの責務分割
  def diameters
    wheels.collect { |wheel| diameter(wheel) }
  end

  def diameter(wheel)
    wheel.rim + (wheel.tirm * 2)
  end
end

class Gear
  attr_reader :chainring, :cog, :rim, :tire

  def initialize(chainring, cog, rim, tire)
    @chainring = chainring
    @cog = cog
    @rim = rim
    @tire = tire
  end

  # gear_inchesも責務分割
  def gear_inches
    # ratio * (rim + tire * 2)
    ratio * diameter
  end

  def diameter
    rim + (tire * 2)
  end
end

# クラス内の余計な責任を隔離する
# GearにはいくつかWheelのような振る舞いがある。
# ただし、今回はwheelクラスをつっくりたくないとする。

class Gear
  attr_reader :chainring, :cog, :wheel

  def initialize(chainring, cog, rim, tire)
    @chainring = chainring
    @cog = cog
    @wheel = Wheel.new(rim, tire)
  end

  def ratio
    chainring / cog.to_f
  end

  def gear_inches
    ratio * wheel.diameter
  end

  Wheel.Struct.new(:rim, :tire) do
    def diameter
      rim + (tire * 2)
    end
  end
end
