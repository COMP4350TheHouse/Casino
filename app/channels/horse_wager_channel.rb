class HorseWagerChannel < ApplicationCable::Channel
  def subscribed
    stream_from "horse_wager_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
