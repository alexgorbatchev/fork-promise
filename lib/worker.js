var ProcessChannel, args, channel, channelId, fn, reject, resolve, _ref, _ref1;

ProcessChannel = require('process-channel').ProcessChannel;

_ref = JSON.parse(process.argv.pop()), channelId = _ref.channelId, args = _ref.args;

channel = new ProcessChannel(process, channelId);

_ref1 = args, fn = _ref1.fn, args = _ref1.args;

if (args == null) {
  args = [];
}

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

process.once('uncaughtException', function(err) {
  reject(err);
  return process.exit(-1);
});

fn = eval("(" + fn + ")");

fn.apply(null, args.concat([resolve, reject]));
