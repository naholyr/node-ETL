csv = require 'csv'
component = require '../etl-component'

# FIXME stupid dumb impl emitting 5 fake lines
module.exports = component
  init: ->
    @count = 0
  read: (n, cb) ->
    if @count == 10
      cb null, null
    else
      @count++
      cb null
        count: @count
        rnd:   Math.ceil(Math.random() * 1000)
