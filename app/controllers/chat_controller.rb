# Manages the messages passed from the front end, propagating them to the proper channels
class ChatController < ApplicationController
  MESSAGE_MAX_LENGTH = 100 # What the max length is in the front-end
  def send_message
    # Prevents XSS by using an HTML escape
    message = ERB::Util.html_escape(params[:input_string])
    channel = params[:channel]
    channel_map = {
      "Global" => "global_channel",
      "Horse Race" => "horse_race_chat_channel",
      "Roulette" => "roulette_channel"
    }

    return if message.empty?

    return if message.length > MESSAGE_MAX_LENGTH

    channel_name = channel_map[channel]
    ActionCable.server.broadcast(channel_name, { body: "#{Current.session.user.username}: #{message}" })
  end
end
