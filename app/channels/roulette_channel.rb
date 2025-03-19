# Channel used for Roulette messages
class RouletteChannel < ApplicationCable::Channel
  def subscribed
    stream_from "roulette_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
