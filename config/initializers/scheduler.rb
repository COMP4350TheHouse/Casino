require 'rufus-scheduler'
require 'date'

scheduler = Rufus::Scheduler.new

last_minute = DateTime.now.minute

MAX_TICK_DELAY = 5
tick_delay = 0

scheduler.every '2s' do
  race_message = {
    horses: Horse.race_message,
    resetting: tick_delay == MAX_TICK_DELAY
  }
  ActionCable.server.broadcast("horse_race_channel", { message: race_message })
  if tick_delay != 0
    tick_delay -= 1
  else
    Horse.all.each(&:tick)
  end

  # Resets the race every minute
  curr_minute = DateTime.now.minute
  if last_minute != curr_minute
    tick_delay = MAX_TICK_DELAY
    last_minute = curr_minute
    Horse.update_all(position: 0)
  end
end
