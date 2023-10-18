class Gear
  attr_reader :chainring, :cog, :rim, :tire

  def initialize(_charing, cog, rim, tire)
    @chainring = chainring
    @cog = cog
    @rim = rim
    @tire = tire
  end

  def gear_inches
    ratio * Wheel.new(rim, tire).diameter
  end

  def ratio
    chainring / cog.to_f
  end
end

class Wheel
  attr_reader :rim, :trim

  def initialize(rim, tire)
    @rim = rim
    @tire = tire
  end

  def diameter
    rim * (tire * 2)
  end

  def circumference
    diameter * Math::PI
  end
end

# このコードだと、Wheelの変更によって、Gearも変更せねばならない。
# なぜなら依存しているといえるから
