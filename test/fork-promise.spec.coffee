require 'coffee-errors'

Promise = require 'bluebird'
chai = require 'chai'
sinon = require 'sinon'
# using compiled JavaScript file here to be sure module works
forkPromise = require '../lib/fork-promise.js'

expect = chai.expect
chai.use require 'sinon-chai'

describe 'fork-promise', ->
  start = null
  duration = null
  results = null

  describe '::file', ->
    describe 'multiple successfull jobs', ->
      before ->
        duration = null
        results = null
        start = Date.now()

        Promise.all [
          forkPromise.file "#{__dirname}/worker.js", foo: 'bar1'
          forkPromise.file "#{__dirname}/worker.js", foo: 'bar2'
          forkPromise.file "#{__dirname}/worker.js", foo: 'bar3'
          forkPromise.file "#{__dirname}/worker.js", foo: 'bar4'
        ]
        .then (r) ->
          results = r
          duration = Date.now() - start

      it 'takes about a second', ->
        expect(Math.floor duration / 1000).to.eql 1

      it 'returns results', ->
        expect(results).to.have.length 4
        expect(results).to.eql [
          {myData: 'ok', args: {foo: 'bar1'}}
          {myData: 'ok', args: {foo: 'bar2'}}
          {myData: 'ok', args: {foo: 'bar3'}}
          {myData: 'ok', args: {foo: 'bar4'}}
        ]

    describe 'failed job', ->
      before ->
        duration = null
        results = null
        start = Date.now()

        forkPromise
          .file "#{__dirname}/worker.js", triggerError: true
          .catch (err) ->
            results = err
            duration = Date.now() - start

      it 'takes about a second', ->
        expect(Math.floor duration / 1000).to.eql 1

      it 'returns error', ->
        expect(results.message).to.eql 'Failed'
        expect(results.stack).to.be.ok

  describe '::fn', ->
    describe 'multiple successfull jobs', ->
      before ->
        duration = null
        results = null
        start = Date.now()

        job = (args, resolve, reject) ->
          finish = -> resolve myData: 'ok', args: args
          setTimeout finish, 1000

        Promise.all [
          forkPromise.fn job, [foo: 'bar1']
          forkPromise.fn job, [foo: 'bar2']
          forkPromise.fn job, [foo: 'bar3']
          forkPromise.fn job, [foo: 'bar4']
        ]
        .then (r) ->
          results = r
          duration = Date.now() - start

      it 'takes about a second', ->
        expect(Math.floor duration / 1000).to.eql 1

      it 'returns results', ->
        expect(results).to.have.length 4
        expect(results).to.eql [
          {myData: 'ok', args: {foo: 'bar1'}}
          {myData: 'ok', args: {foo: 'bar2'}}
          {myData: 'ok', args: {foo: 'bar3'}}
          {myData: 'ok', args: {foo: 'bar4'}}
        ]

    describe 'failed job', ->
      before ->
        duration = null
        results = null
        start = Date.now()

        job = (resolve, reject) ->
          finish = -> reject new Error 'Failed'
          setTimeout finish, 1000

        forkPromise
          .fn job
          .catch (err) ->
            results = err
            duration = Date.now() - start

      it 'takes about a second', ->
        expect(Math.floor duration / 1000).to.eql 1

      it 'returns error', ->
        expect(results.message).to.eql 'Failed'
        expect(results.stack).to.be.ok

    describe 'runtime error', ->
      before ->
        duration = null
        results = null
        start = Date.now()

        job = (resolve, reject) ->
          finish = ->
            i = null
            i.foo()

          setTimeout finish, 1000

        forkPromise
          .fn job
          .catch (err) ->
            results = err
            duration = Date.now() - start

      it 'takes about a second', ->
        expect(Math.floor duration / 1000).to.eql 1

      it 'returns error', ->
        expect(results.message).to.eql "Cannot call method \'foo\' of null"
        expect(results.stack).to.be.ok
