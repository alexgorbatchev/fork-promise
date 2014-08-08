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
  return channel;
};

file = function(workerScript, args) {
  return new Promise(function(resolve, reject) {
    var channel;
    channel = start(workerScript, args);
    channel.once('error', reject);
    return channel.once('done', resolve);
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
