{ProcessChannel} = require 'process-channel'

{channelId, args} = JSON.parse process.argv.pop()
channel = new ProcessChannel process, channelId

{fn, args} = args
args ?= []

callback = (err, results) ->
  if err?
    channel.send 'error', stack: err.stack,  message: err.message
    process.exit -1

  channel.send 'done', results
  process.exit()

process.once 'uncaughtException', callback

fn = eval "(#{fn})"
fn.apply null, args.concat [callback]
