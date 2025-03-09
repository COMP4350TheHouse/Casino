require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.every '2s' do
  ActionCable.server.broadcast("horse_race_channel", { message: Horse.race_message })
  Horse.all.each(&:tick)
end
