class SidekiqSchedulerBackoffService
  attr_reader :name, :min_interval, :max_interval

  def initialize(name:, min_interval:, max_interval:)
    @name = name.to_s
    @min_interval = min_interval
    @max_interval = max_interval
  end

  def record_success
    initial_interval = current_interval
    target_interval = [initial_interval - 1, min_interval].max
    restart_schedule(target_interval) if target_interval != initial_interval
  end

  def record_failure
    initial_interval = current_interval
    target_interval = [initial_interval * 2, max_interval].min
    restart_schedule(target_interval) if target_interval != initial_interval
  end

private

  def current_interval
    schedule = Sidekiq.get_schedule[name]
    Integer(schedule["every"].chop)
  end

  def restart_schedule(target_interval)
    schedule = Sidekiq.get_schedule[name]
    Sidekiq.set_schedule(name, schedule.merge("every" => "#{target_interval}s"))
  end
end
