var ProcessChannel, args, callback, channel, channelId, fn, _ref, _ref1;

ProcessChannel = require('process-channel').ProcessChannel;

_ref = JSON.parse(process.argv.pop()), channelId = _ref.channelId, args = _ref.args;

channel = new ProcessChannel(process, channelId);

_ref1 = args, fn = _ref1.fn, args = _ref1.args;

if (args == null) {
  args = [];
}

callback = function(err, results) {
  if (err != null) {
    channel.send('error', {
      stack: err.stack,
      message: err.message
    });
    process.exit(-1);
  }
  channel.send('done', results);
  return process.exit();
};

process.once('uncaughtException', callback);

fn = eval("(" + fn + ")");

fn.apply(null, args.concat([callback]));
