# クラスで分岐するcase文
class Trip
  attr_reader :bicycles, :customers, :vehicle

  def prepare(preparers)
    preparers.each do |preparer|
      case preparer
      when Mechanic
        preparer.prepare_bicycles(bicycles)
      when TripCoordinator
        preparer.buy_food(customers)
      when Driver
        preparer.gas_up(vehicle)
        preparee.fill_water_tank(vehicle)
      end
    end
  end
end

# kind_of? と is_a?
if preparer.is_a?(Mechanic)
  preparer.prepare_bicycles(bicycles)
elsif preparer.is_a?(TripCoordinator)
  preparer.buy_food(customers)
elsif preparer.is_a?(Driver)
  preparer.gas_up(vehicle)
  preparer.fill_water_tank(vehicle)
end

# responds_to?
if preparer.respond_to?(:prepare_bicycles)
  preparer.prepare_bicycles
elsif preparer.respond_to?(:buy_food)
  preparer.buy_food(customers)
elsif preparer.respond_to?(:gas_up)
  preparer.gas_up(vehicle)
  preparer.fill_water_tank(vehicle)
end
# このコードは他のオブジェクトを信頼するというよりも、制御しています。

### 賢くダックを選ぶ
# このメソッドには find(:first) メソッドと同じ引数を全て渡せる。
def first(*args)
  if args.any?
    if args.first.is_a?(Integer) || (logged? && !args.first.is_a?(hash))
      to_a.first(*args)
    else
      apply_finder_options(args.first).first
    end
  else
    find_first
  end
end

# https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-first
# Array#first(n) -> Array
# 先頭の n 要素を配列で返します。n は 0 以上でなければなりません。
