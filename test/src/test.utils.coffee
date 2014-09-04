'use strict'

{expect} = require 'chai'
utils = require '../index'

describe 'util functions', ->
  it 'should properly create map stream', (done) ->
    gen_stream = utils.from [1, 2, 3, 4]
    string_stream = utils.map (data, enc, next) -> next null, ++data
    dumper = utils.dumper [], (result) ->
      expect(result[0]).equals 2
      done()
    gen_stream.pipe(string_stream).pipe(dumper)

  it 'should properly create cartesian stream', (done) ->
    products = [1..10]
    suburbs  = ["ALBANY", "ALEXANDER HEIGHTS", "ALFRED COVE", "APPLECROSS", "ARMADALE"]

    cartesian_stream = utils.cartesian suburbs, products
    url_stream = utils.map (tuple, enc, next) ->
      url = "http://www.fuelwatch.wa.gov.au/fuelwatch/fuelWatchRSS?Product=#{tuple[1]}&Suburb=#{tuple[0]}&Surrounding=no"
      next null, url

    dumper = utils.dumper [], (result) ->
      console.log result
      done()

    cartesian_stream.pipe(url_stream).pipe dumper