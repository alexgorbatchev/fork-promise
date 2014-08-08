{ProcessChannel} = require 'process-channel'

{channelId, args} = JSON.parse process.argv.pop()
channel = new ProcessChannel process, channelId

{fn, args} = args
args ?= []

resolve = (results) ->
  channel.send 'done', {results}
  process.exit()

reject = (err) ->
  channel.send 'done', err: stack: err.stack,  message: err.message
  process.exit -1

process.once 'uncaughtException', (err) ->
  reject err
  process.exit -1

fn = eval "(#{fn})"
fn.apply null, args.concat [resolve, reject]
