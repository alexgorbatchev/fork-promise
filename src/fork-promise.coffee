{fork} = require 'child_process'
Promise = require 'bluebird'
{ProcessChannel} = require 'process-channel'

start = (workerScript, args) ->
  channelId = Math.round Math.random() * 999999999
  worker = fork workerScript, [JSON.stringify {channelId, args}]
  channel = new ProcessChannel worker, channelId
  channel

file = (workerScript, args) ->
  new Promise (resolve, reject) ->
    channel = start workerScript, args
    channel.once 'error', reject
    channel.once 'done', resolve

fn = (workerFunction, args, workerScript = "#{__dirname}/worker.js") ->
  file workerScript, {args, fn: workerFunction.toString()}

module.exports = {fn, file}
