{fork} = require 'child_process'
Promise = require 'bluebird'
{ProcessChannel} = require 'process-channel'

start = (workerScript, args) ->
  channelId = Math.round Math.random() * 999999999
  worker = fork workerScript, [JSON.stringify {channelId, args}]
  channel = new ProcessChannel worker, channelId
  {worker, channel}

file = (workerScript, args) ->
  new Promise (resolve, reject) ->
    err = null
    results = null
    {worker, channel} = start workerScript, args

    channel.once 'done', (data) ->
      {err, results} = data

    worker.once 'exit', (exitCode) ->
      err ?= new Error "Exit code: #{exitCode}" if exitCode isnt 0
      if err? then reject err else resolve results

fn = (workerFunction, args, workerScript = "#{__dirname}/worker.js") ->
  file workerScript, {args, fn: workerFunction.toString()}

module.exports = {fn, file}
