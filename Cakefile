### from
http://www.scribd.com/doc/39488472/Coffee-Script-Premiere
###

sys = require 'sys'
fs = require 'fs'
exec = require('child_process').exec
spawn = require('child_process').spawn

task "hello", "hello world", ->
  sys.puts "hello"

task 'watch', 'watches and compiles coffee file', ->
  sys.puts "Spawning coffee watcher..."
  coffee = spawn 'coffee', ['-cwl', '-o', "js", "coffees"]
  
  [coffee].forEach (child) ->
    child.stdout.on 'data', (data) ->
      sys.print data
      exec "notify-send Cakefile \"#{data}\""
    child.stderr.on 'data', (data) ->
      sys.print data
      exec "notify-send \"Cakefile(fail)\" \#{data}\""
  
