var ProcessChannel = require('process-channel').ProcessChannel;
var params = JSON.parse(process.argv.pop());
var channelId = params.channelId;
var args = params.args;
var channel = new ProcessChannel(process, params.channelId);

reject = function(err) {
  channel.send('done', {
    err: {
      stack: err.stack,
      message: err.message
    }
  });
  return process.exit(-1);
};

setTimeout(function() {
  channel.send('done', {
    results: {myData: 'ok', args: args}
  });
  return process.exit();
}, 1000);
