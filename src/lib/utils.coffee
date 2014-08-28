'use strict'

{Readable, Writable, Transform, PassThrough} = require 'stream'
utils = {}

# Helpers
__toString = Object::toString
array_type = '[object Array]'
isArray = (obj) ->
  if array_type is __toString.call obj
    return true
  return false

function_type = "function"
isFunction = (obj) -> function_type is typeof obj

# Classes
class readStream extends Readable
  constructor: (@source, objectMode = true) -> super {objectMode}
  _read: (size) -> @source.call @, size

class MapStream extends Transform
  constructor: (@task, objectMode = true) -> super {objectMode}
  _transform: (chunk, enc, next) ->
    @task.call @, chunk, (error, data) =>
      if error then return @emit 'error', error
      @push data
      next error

class FilterStream extends Transform
  constructor: (@predicate, objectMode = true) -> super {objectMode}
  _transform: (chunk, enc, next) ->
    @predicate.call @, chunk, (error, status) =>
      if error then return @emit 'error', error
      if status is true
        @push chunk
      next error

class writeStream extends Writable
  constructor: (@task, @done, objectMode = true) ->
    super {objectMode}
    if isFunction @done
      @on 'finish', => @done.call @

  _write: (chunk, enc, next) ->
    @task.call @, chunk, (error) ->
      if error then return @emit 'error', error
      next error

# Functions
utils.map    = (task) -> new MapStream task
utils.filter = (predicate) -> new FilterStream predicate
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
  new readStream reader

# Takes an array of values and repeatedly streams all values.
utils.repeat = (values) ->
  if not isArray values then values = [values]
  max_length = values.length
  index = 0
  reader = (size) ->
    @push values[index]
    index = (index + 1) % max_length
  new readStream reader

utils.dumper = (container, onEnd) ->
  task = (chunk, next) ->
    container.push chunk
    next()
  finish = -> onEnd container
  new writeStream task, finish

module.exports = utils