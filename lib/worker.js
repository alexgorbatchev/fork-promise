var Channel, channel, channelId;

Channel = require('./channel').Channel;

channelId = process.argv.pop();

channel = new Channel(channelId, process);

channel.once('run', function(_arg) {
  var args, fn, reject, resolve;
  fn = _arg.fn, args = _arg.args;
  resolve = function(results) {
    channel.send('done', {
      results: results
    });
    return process.exit();
  };
  reject = function(err) {
    channel.send('done', {
      err: {
        stack: err.stack,
        message: err.message
      }
    });
    return process.exit(-1);
  };
  process.on('uncaughtException', function(err) {
    reject(err);
    return process.exit(-1);
  });
  fn = eval("(" + fn + ")");
  return fn.apply(null, args.concat([resolve, reject]));
});

channel.send('ready');