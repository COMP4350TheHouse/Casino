# Manages the messages passed from the front end, propagating them to the proper channels
class ChatController < ApplicationController
  def send_message
    message = params[:input_string]
    channel = params[:channel]
    channel_map = {
      "Global" => "global_channel",
      "Horse Race" => "horse_race_chat_channel",
      "Roulette" => "roulette_channel"
    }

    return if message.empty?

    # This matches with the input form on the front end
    return unless message.match? /\A[a-zA-Z'-]*\z/

    channel_name = channel_map[channel]
    ActionCable.server.broadcast(channel_name, { body: "#{Current.session.user.username}: #{message}" })
  end
end
