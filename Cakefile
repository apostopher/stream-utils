{exec}  = require 'child_process'

task 'clean', 'Clean the directory by removing *.js', ->
  exec "rm -rf *.js test/*.js lib/*.js", (error) -> if error then throw error

task 'compile', 'Compile individual files', ->
  exec "coffee -co . src", (error) ->
    if error then throw error


task 'test', 'Compile individual test cases', ->
  exec "coffee -co test/ test/src", (error) ->
    if error then throw error

task 'build', 'build module and tests', ->
  console.log process.cwd()
  invoke 'compile'
  invoke 'test'
