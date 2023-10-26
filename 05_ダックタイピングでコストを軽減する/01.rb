class Trip
  attr_reader :bicycles, :customers, :vehicle

  # このmechanic　引数は、どんなクラスのものでも良い
  def prepare(mechanic)
    mechanic.prepare_bicycles(bicycles)
  end

  # ...
end

# このクラスのインスタンスを渡すことになったとしても、動作する。
class Mechanic
  def prepare_bicycles(bicycles)
    bicycles.each { |bicycle| prepare_bicycle(bicycle) }
  end

  def prepare_bicycle(bicycle)
    # ...
  end
end

# コーディネーターと運転手を追加
class Trip
  attr_reader :bicycles, :customers, :vehicle

  # prepareでは異なる3つのクラスを名前で参照している上に、
  # それぞれに実装されている具体的なメソッドを知っている。これは危険！
  def prepare(prepares)
    prepares.each do |prepare|
      case preparer
      when Mechanic
        prepare.prepare_bicycles(bicycles)
      when TripCoordinator
        prepare.buy_food(customers)
      when Driver
        prepare.gas_up(vehicle)
        prepare.fill_water_tank(vehicle)
      end
    end
  end
end

class TripCoordinator
  def buy_food(customers)
    # ...
  end
end

class Driver
  def gas_up(vehicle)
    # ...
  end

  def fill_water_tank(vehicle)
    # ...
  end
end

# 新しい設計。preparaメソッドは引数が複数のPreparerであることを想定しています。
class Trip
  attr_reader :bicycle, :customer, :vehicle

  def prepare(prepares)
    prepares.each do |prepare|
      prepare.prepare_trip(self)
    end
  end
end

# 全ての準備者(Preparer)は、
# prepare_tripに応答するダック
class Mechanic
  def prepare_trip(trip)
    trip.bicycle.each do |bicycle|
      prepare_bicycle(bicycle)
    end
  end

  # ...
end

class TripCoordinator
  def prepare_trip(trip)
    buy_food(trip.customers)
  end
end

class Driver
  def prepare_trip(trip)
    vehicle = trip.vehicle
    gas_up
    fill_water_tank(vehicle)
  end
end
# このprepareメソッドは、新しいPreparerを受け入れる際に、変更が強制されることはありません。
# また、必要に応じて追加のPreparerを作るのも簡単です。
