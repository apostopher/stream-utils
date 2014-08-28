'use strict'

{expect} = require 'chai'
utils = require '../index'

describe 'util functions', ->
  it 'should properly create map stream', (done) ->
    gen_stream = utils.from [1, 2, 3, 4]
    string_stream = utils.map (data, next) -> next null, ++data
    dumper = utils.dumper [], (result) ->
      expect(result[0]).equals 2
      done()
    gen_stream.pipe(string_stream).pipe(dumper)