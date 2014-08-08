var ProcessChannel = require('process-channel').ProcessChannel;
var opts = JSON.parse(process.argv.pop());
var channel = new ProcessChannel(process, opts.channelId);

process.once('uncaughtException', function(err) {
  // Have to assemble an object that looks like `Error` because
  // instances of `Error` doesn't stringify well
  channel.send('error', {stack: err.stack, message: err.message});
  process.exit(-1);
});

setTimeout(function() {
  if(opts.args.triggerError)
    throw new Error('Failed');

  channel.send('done', {myData: 'ok', args: opts.args});
  process.exit();
}, 1000);
