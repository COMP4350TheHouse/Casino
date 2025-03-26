// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the `bin/rails generate channel` command.

// Importing the `createConsumer` function to establish websockets
import { createConsumer } from "@rails/actioncable"

// Exporting the default Action Cable consumer, which allows the client to connect to websocket channels for the casino
export default createConsumer()
