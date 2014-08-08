var ProcessChannel, Promise, file, fn, fork, start;

fork = require('child_process').fork;

Promise = require('bluebird');

ProcessChannel = require('process-channel').ProcessChannel;

start = function(workerScript, args) {
  var channel, channelId, worker;
  channelId = Math.round(Math.random() * 999999999);
  worker = fork(workerScript, [
    JSON.stringify({
      channelId: channelId,
      args: args
    })
  ]);
  channel = new ProcessChannel(worker, channelId);
  return {
    worker: worker,
    channel: channel
  };
};

file = function(workerScript, args) {
  return new Promise(function(resolve, reject) {
    var channel, err, results, worker, _ref;
    err = null;
    results = null;
    _ref = start(workerScript, args), worker = _ref.worker, channel = _ref.channel;
    channel.once('done', function(data) {
      return err = data.err, results = data.results, data;
    });
    return worker.once('exit', function(exitCode) {
      if (exitCode !== 0) {
        if (err == null) {
          err = new Error("Exit code: " + exitCode);
        }
      }
      if (err != null) {
        return reject(err);
      } else {
        return resolve(results);
      }
    });
  });
};

fn = function(workerFunction, args, workerScript) {
  if (workerScript == null) {
    workerScript = "" + __dirname + "/worker.js";
  }
  return file(workerScript, {
    args: args,
    fn: workerFunction.toString()
  });
};

module.exports = {
  fn: fn,
  file: file
};
