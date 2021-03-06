# fork-promise

[![GitTip](http://img.shields.io/gittip/alexgorbatchev.svg?style=flat)](https://www.gittip.com/alexgorbatchev/)
[![Dependency status](http://img.shields.io/david/alexgorbatchev/fork-promise.svg?style=flat)](https://david-dm.org/alexgorbatchev/fork-promise)
[![devDependency Status](http://img.shields.io/david/dev/alexgorbatchev/fork-promise.svg?style=flat)](https://david-dm.org/alexgorbatchev/fork-promise#info=devDependencies)
[![Build Status](http://img.shields.io/travis/alexgorbatchev/fork-promise.svg?style=flat&branch=master)](https://travis-ci.org/alexgorbatchev/fork-promise)

[![NPM](https://nodei.co/npm/fork-promise.svg?style=flat)](https://npmjs.org/package/fork-promise)

Executes code in a forked Node.js process and returns a [Bluebird](https://github.com/petkaantonov/bluebird) promise. This is useful for parallelizing heavy tasks and taking advantage of multiple CPUs/cores.

Please note, this is only useful for splitting up long running tasks because [according to the doc](http://nodejs.org/api/child_process.html#child_process_child_process_fork_modulepath_args_options):

> These child Nodes are still whole new instances of V8. Assume at least 30ms startup and 10mb memory for each new Node. That is, you cannot create many thousands of them.

## Installation

    npm install fork-promise

## Usage Example

In the example below the `job` function will be executed in a forked process. Please note there is parent scope access and the `job` function is executed in the global context of the new process.

```javascript
var forkPromise = require('fork-promise');

function job(arg1, arg2, done) {
  setTimeout(function() {
    done(null, {prop: 'value'});
  }, 500);
}

forkPromise
  .fn(job, ['arg1', 'arg2'])
  .then(function(results) {
    console.log(results.prop);
  });
```

## API

### file(scriptFile, args) -> Promise

Executes a `scriptFile` passing in `args` via JSON string and returns a `Promise`. The script file has to implement the following interface:

```javascript
var ProcessChannel = require('process-channel').ProcessChannel;
var opts = JSON.parse(process.argv.pop());
var channel = new ProcessChannel(process, opts.channelId);

process.once('uncaughtException', function(err) {
  // Have to assemble an object that looks like `Error` because
  // instances of `Error` doesn't stringify well
  channel.send('error', {stack: err.stack, message: err.message});
  process.exit(-1);
});

// opts.args is the JSON parsed copy of `args`

// Do work and when done, call:
channel.send('done', resultsObject);

// Need to exit because we have event handler on `process`
process.exit();
```

### fn(function, args) -> Promise

Executes `function` in a forked process applying `args` to it (which means `args` must be an array or null). **Please note that `function` doesn't have access to the outside scope because it's stringified and passed to another process.**

```javascript
var forkPromise = require('fork-promise');

var myVar = 123;

function job(arg1, arg2, done) {
  // >>>> NO ACCESS TO myVar HERE <<<<
  setTimeout(function() {
    done(null, {prop: 'value'});
  }, 500);
}

forkPromise
  .fn(job, ['arg1', 'arg2'])
  .then(function(results) {
    console.log(results.prop);
  });
```

## Testing

    npm test

## License

The MIT License (MIT)

Copyright 2014 Alex Gorbatchev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
