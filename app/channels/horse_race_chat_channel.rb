# Sends messages in the horse race chat channel
class HorseRaceChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "horse_race_chat_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
