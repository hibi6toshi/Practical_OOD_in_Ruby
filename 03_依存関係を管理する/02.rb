# 依存オブジェクトの注入

class Gear
  def gear_inches
    ratio * Wheel.new(rim, trim).diameter
  end
end

# gear_inchesはWheelに対して明示的に参照しています。
# GearからWheelへの参照がgeargear_inchesメソッド内という深いところでハードコーディングされている場合、
# それは、明示的に「Wheelインスタンスのギアインチしか計算する意思はない」ということを表している。
# → ディスクやシリンダといったオブジェクトがアプリに追加され、そのギアインチを知りたい場合でも、Gearクラスは使うことができない。
# GeaarはWheelと結合しているため、それらを計算できない。

# 重要なのはクラスではなく、メッセージ！
# （Wheelクラスに着目するのではなく、「diameterというメッセージを受信できる」という点に着目する）

class Gear
  attr_reader :chainring, :cog, :wheel # このwheelは「diameter-able_obj的な意味合いで捉える。

  def initialize(_chainring, cog, wheel)
    @chainring = chainring
    @cog = cog
    @wheel = wheel
  end

  def gear_inches
    ratio * wheel.diameter
  end
end

# Gearは'diameter'を知る'Duck'を要求する。
Gear.new(52, 11, Wheel.new(26, 2.5)).gear_inches

# wheelのインスタンス生成をGearの外に移動することで、2つのクラスの結合が切り離されます。

# インスタンス変数の作成を分離する
# WheelをGearに注入するような変更ができないときはどうするか。

# → Wheel のインスタンス生成をGearクラス内で分離すべき。

# Wheelのインスタンス生成を、Gearのinitializeで行う。
class Gear
  attr_reader :chainring, :cog, :rim, :tire

  def initialize(chainring, cog, rim, tire)
    @chainring = chainring
    @cog = cog
    @wheel = Wheel.new(rim, tire)
  end

  def gear_inches
    ratio * wheel.diameter
  end
end

# 作成を隔離し、￥独自に明示的に定義したWheelメソッド内で行うようにする。
# こちらだと必要になるまで、Wheelのインスタンスは作られない。
class Gear
  atrt_reader :chainring, :cog, :rim, :tire

  def initialize(chainring, cog, rim, tire)
    @chainring = chainring
    @cog = cog
    @rim = rim
    @tire = tire
  end

  def gear_inches
    ratio * wheel.diameter
  end

  def wheel
    @wheel ||= Wheel.new(rim, tire)
  end
end

# gear_inches内の依存数は減り、同時にGearがWheelに依存していることが公然となりました。
# 依存を隠蔽するのではなく、明らかにします。

# 外部へのメッセージを隔離する。
class Gear
  def gear_inches
    ratio * wheel.diameter
  end
end

# 上記のような単純なメソッドであればいいが、複雑な処理の途中で外部への依存(self以外への呼び出し)を行うのは危険。
# 専用のメソッド内にカプセル化する。
class Gear
  def gear_inches
    ratio * diameter
  end

  def diameter
    wheel.diameter
  end
end
# Wheelがdiameterについて、名前やシグニチャの変更をおこなったとしてもGearへの副作用はラッパーメソッドの中だけですみます。

# 複数のパラメータを用いた初期化を隔離する。

# 依存せざるを得ないメソッドが固定の引数順を要求し、しかもそれが外部のものである場合があります。
# その場合はそのメソッドもDRYにする。

module SomeFramework
  class Gear
    attr_reader :chainring, :cog, :wheel

    def initialize(chainring, cog, wheel)
      @chainring = chainring
      @cog = cog
      @wheel = wheel
    end

    # ...
  end
end

# 外部のインターフェースをラップし、自信を変更から守る
module GearWrapper
  def self.gear(args)
    SomeFramework::Gear.new(args[:chainring],
                            args[:cog],
                            args[:wheel])
  end
end

GearWrapper.gear(
  chainring: 52,
  cog: 11,
  wheel: Wheel.new(26, 1, 5)
).gear_inches

# GearWrapperをモジュールにすることで、GearWrapper自体はインスタンス化して使うものではないことがわかる。
