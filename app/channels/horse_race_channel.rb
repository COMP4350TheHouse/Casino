# Channel used for horse race messages
class HorseRaceChannel < ApplicationCable::Channel
  def subscribed
    stream_from "horse_race_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
