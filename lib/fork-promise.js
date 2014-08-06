var ProcessChannel, Promise, fork, run,
  __slice = [].slice;

fork = require('child_process').fork;

Promise = require('bluebird');

ProcessChannel = require('process-channel').ProcessChannel;

run = function() {
  var args, fn;
  fn = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
  return new Promise(function(resolve, reject) {
    var channel, channelId, err, results, worker;
    err = null;
    results = null;
    channelId = Math.round(Math.random() * 999999999);
    worker = fork("" + __dirname + "/worker.js", [channelId]);
    channel = new ProcessChannel(worker, channelId);
    channel.once('ready', function() {
      return channel.send('run', {
        fn: fn.toString(),
        args: args
      });
    });
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

module.exports = {
  run: run
};
