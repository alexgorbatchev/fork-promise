{Channel} = require './channel'

channel = new Channel()

send = (type, data) ->
  process.send JSON.stringify {type, data}

process.on 'message', (json) ->
  {type, data} = JSON.parse json
  handlers[type] data

handlers =
  run: ({fn, args}) ->
    resolve = (results) ->
      send 'done', {results}
      process.exit()

    reject = (err) ->
      send 'done', {err}
      process.exit -1

    fn = eval "(#{fn})"
    fn.apply null, args.concat [resolve, reject]

send 'ready'
