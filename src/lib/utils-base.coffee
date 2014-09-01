'use strict'

{Readable, Writable, Transform, PassThrough} = require 'stream'

isFunction = (obj) -> "function" is typeof obj


readStream = (source, objectMode = true) -> 
  stream = new Readable {objectMode}
  stream._read = (size) ->
    try
      source.call stream, size
    catch error
      stream.emit 'error', error
  stream

mapStream = (task, objectMode = true) ->
  stream = new Transform {objectMode}
  stream._transform = (chunk, enc, next) ->
    try
      task.call stream, chunk, enc, (error, data) =>
        if error then return stream.emit 'error', error
        stream.push data
        next error
    catch error
      stream.emit 'error', error
  stream

filterStream = (predicate, objectMode = true) ->
  stream = new Transform {objectMode}
  stream._transform = (chunk, enc, next) ->
    try
      predicate.call stream, chunk, enc, (error, status) =>
        if error then return stream.emit 'error', error
        if status is true
          stream.push chunk
        next error
    catch error
      stream.emit 'error', error
  stream

reduceStream = (reducer, memo, objectMode = true) ->
  stream = new Transform {objectMode}
  stream._transform = (chunk, enc, next) ->
    try
      reducer.call stream, memo, chunk, enc, (error, data) =>
        if error then return stream.emit 'error', error
        memo = data
        stream.push data
        next error
    catch error
      stream.emit 'error', error
  stream

writeStream = (task, done, objectMode = true) ->
  stream = new Writable {objectMode}
  if isFunction done
    stream.on 'finish', -> done.call stream

  stream._write = (chunk, enc, next) ->
    try
      task.call stream, chunk, enc, (error) ->
        if error then return stream.emit 'error', error
        next error
    catch error
      stream.emit 'error', error
  stream
    

module.exports = {readStream, mapStream, filterStream, reduceStream, writeStream}