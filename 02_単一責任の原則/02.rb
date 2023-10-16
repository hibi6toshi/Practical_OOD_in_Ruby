chainring= 52
cog = 11
ratio = chainring/ cog.to_f
puts ratio
# => 4.7272727272727275

chainring= 30
cog = 27
ratio = chainring/ cog.to_f
puts ratio
#  => 1.1111111111111112

# クラスはそれぞれのドメインの一部を表します。
# 自転車とギアについて、今のところはギアについてはデータと振る舞いがあるのでクラスにできそう

class Gear
  attr_reader :chainring, :cog

  def initialize(chainring, cog)
    @chainring= chainring
    @cog = cog
  end

  def ratio
    @chainring/ cog
  end
end

puts Gear.new(52, 11).ratio
# => 4.7272727272727275
puts Gear.new(30, 27).ratio
# => 1.1111111111111112

# 車輪の大きさによる違いも反映したい。
# ギアインチで比較する。
# ギアインチ=車輪の直径*ギア比
# 車輪の直径=リムの直径+(タイヤの厚み)*2

class Gear
  attr_reader :chainring, :cog, :rim, :tire

  def initialize(chainring, cog, rim, tire)
    @chainring= chainring
    @cog = cog
    @rim = rim
    @tire = tire
  end

  def gear_inches
    ratio * (rim + tire * 2)
  end
end

puts Gear.new(52, 11, 26, 1.5).gear_inches
#=> 137.0909090909091
