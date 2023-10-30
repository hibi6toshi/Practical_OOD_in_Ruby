class Schedule
  def schedule?(_shedulable, start_date, end_date)
    puts "This #{schedulable.class}" +
         "is not scheduled\n" +
         " between #{start_date} and #{end_date}"
    false
  end
end

class Bicycle
  attr_reader :schedule, :size, :chain, :tire_size

  # Scheduleを注入し、初期値を設定する
  def iniitialize(_args = {})
    @schedule = args = [:schedule] || Schedule.new
    # ...
  end

  # 与えられた期間（現在はBicycleに固有）の間
  # bicycleが利用可能であればtrueをかえす
  def schedulable?(start_date, end_date)
    !scheduled?(start_date - lead_days, end_date)
  end

  # scheduleの答えを返す。
  def sheduled?(start_date, end_date)
    schedule.scheduled?(self, start_date, end_date)
  end

  # bicycleがスケジュール可能となるまでの準備日数を返す
  def lead_days
    1
  end

  # ...
end

module Schedulable
  attr_writer :schedule

  def schedule
    @schedule ||= ::Schedule.new
  end

  def schedulable?(start_date, end_date)
    !scheduled?(start_date - lead_days, end_date)
  end

  def scheduled?(start_date, end_date)
    schedule.scheduled?(self, start_date, end_date)
  end

  # 必要に応じてインクルードする側で置き換える
  def lead_days
    0
  end
end

class Bicycle
  include Schedulable

  def lead_days
    1
  end
end

class Vehicle
  include Schedulable

  def lead_days
    3
  end

  # ...
end

class Mechanic
  include Schedulable

  def lead_days
    4
  end

  # ...
end
