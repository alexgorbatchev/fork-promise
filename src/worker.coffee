{Channel} = require './channel'

channelId = process.argv.pop()
channel = new Channel channelId, process

channel.once 'run', ({fn, args}) ->
  resolve = (results) ->
    channel.send 'done', {results}
    process.exit()

  reject = (err) ->
    channel.send 'done', {err}
    process.exit -1

  fn = eval "(#{fn})"
  fn.apply null, args.concat [resolve, reject]

channel.send 'ready'
