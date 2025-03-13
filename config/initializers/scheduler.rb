require 'rufus-scheduler'
require 'date'

scheduler = Rufus::Scheduler.new

last_minute = DateTime.now().minute
tick_delay = 0


scheduler.every '2s' do
  ActionCable.server.broadcast("horse_race_channel", { message: Horse.race_message })

  if tick_delay != 0
    tick_delay -= 1
  else
    puts "Ticking"
    Horse.all.each(&:tick)
  end


  # Resets the race every minute
  curr_minute = DateTime.now().minute
  if last_minute != curr_minute
      tick_delay = 5
      last_minute = curr_minute
      Horse.update_all(position: 0)
  end
  puts tick_delay
end
