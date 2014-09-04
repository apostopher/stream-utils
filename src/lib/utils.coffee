'use strict'
{readStream, mapStream, filterStream, reduceStream, writeStream} = require './utils-base'
utils = {}

# Helpers
isArray = Array.isArray

# Functions
utils.map    = (task) -> mapStream task
utils.filter = (predicate) -> filterStream predicate
utils.reduce = (reducer) -> reduceStream reducer

utils.merge  = (streams...) ->
  merge_stream = new PassThrough()
  stream.pipe merge_stream for stream in streams
  merge_stream

# Takes an array of values and streams all the values one by one.
utils.from = (values) ->
  if not isArray values then values = [values]
  max_length = values.length
  index = 0
  reader = (size) ->
    if index >= max_length then return @push null
    @push values[index]
    index += 1
  readStream reader

# Takes an array of values and repeatedly streams all values.
utils.repeat = (values) ->
  if not isArray values then values = [values]
  max_length = values.length
  index = 0
  reader = (size) ->
    @push values[index]
    index = (index + 1) % max_length
  readStream reader

utils.dumper = (container, onEnd) ->
  task = (chunk, enc, next) ->
    container.push chunk
    next()
  finish = -> onEnd container
  writeStream task, finish

utils.save = (task, onEnd) -> writeStream task, onEnd

utils.cartesian = (arrays...) ->
  result = []
  max = arrays.length - 1
  iter = (arr, index) ->
    for item in arrays[index]
      a = arr.slice 0
      a.push item
      if index is max
        result.push a
      else
        iter a, index + 1

  iter [], 0
  utils.from result


module.exports = utils