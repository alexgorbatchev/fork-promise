{EventEmitter} = require 'events'

class Channel extends EventEmitter
  constructor: (channelId, @process) ->
    @channelId = channelId.toString()

    handler = (json) =>
      {type, data, id} = JSON.parse json
      @emit type, data if @channelId is id

    @process.on 'message', handler

  send: (type, data) ->
    @process.send JSON.stringify {type, data, id: @channelId}

module.exports = {Channel}
