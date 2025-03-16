# Channel used for global messages
class GlobalChannel < ApplicationCable::Channel
  def subscribed
    stream_from "global_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
