require 'coffee-errors'

Promise = require 'bluebird'
chai = require 'chai'
sinon = require 'sinon'
# using compiled JavaScript file here to be sure module works
webworkerThreadsPromise = require '../lib/webworker-threads-promise.js'

expect = chai.expect
chai.use require 'sinon-chai'

describe 'webworker-threads-promise', ->
  start = null
  duration = null
  results = null

  before ->
    duration = null
    results = null
    start = Date.now()

  describe '::run', ->
    describe 'multiple successfull jobs', ->
      before ->
        job = (args, resolve, reject) ->
          finish = -> resolve myData: 'ok', args: args
          setTimeout finish, 1000

        Promise.all [
          webworkerThreadsPromise.run job, foo: 'bar1'
          webworkerThreadsPromise.run job, foo: 'bar2'
          webworkerThreadsPromise.run job, foo: 'bar3'
          webworkerThreadsPromise.run job, foo: 'bar4'
        ]
        .then (r) ->
          results = r
          duration = Date.now() - start

      it 'takes about a second for all jobs', ->
        expect(Math.floor duration / 1000).to.eql 1

      it 'returns results', ->
        expect(results).to.have.length 4
        expect(results).to.eql [
          {myData: 'ok', args: {foo: 'bar1'}}
          {myData: 'ok', args: {foo: 'bar2'}}
          {myData: 'ok', args: {foo: 'bar3'}}
          {myData: 'ok', args: {foo: 'bar4'}}
        ]
