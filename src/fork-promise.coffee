{fork} = require 'child_process'
Promise = require 'bluebird'
{ProcessChannel} = require 'process-channel'

run = (fn, args...) ->
  new Promise (resolve, reject) ->
    err = null
    results = null
    channelId = Math.round Math.random() * 999999999
    worker = fork "#{__dirname}/worker.js", [channelId]
    channel = new ProcessChannel worker, channelId

    channel.once 'ready', ->
      channel.send 'run', fn: fn.toString(), args: args

    channel.once 'done', (data) ->
      {err, results} = data

    worker.once 'exit', (exitCode) ->
      err ?= new Error "Exit code: #{exitCode}" if exitCode isnt 0
      if err? then reject err else resolve results

module.exports = {run}
