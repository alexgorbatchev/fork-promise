{ProcessChannel} = require 'process-channel'

channelId = process.argv.pop()
channel = new ProcessChannel process, channelId

channel.once 'run', ({fn, args}) ->
  resolve = (results) ->
    channel.send 'done', {results}
    process.exit()

  reject = (err) ->
    channel.send 'done', err: stack: err.stack,  message: err.message
    process.exit -1

  process.on 'uncaughtException', (err) ->
    reject err
    process.exit -1

  fn = eval "(#{fn})"
  fn.apply null, args.concat [resolve, reject]

channel.send 'ready'
