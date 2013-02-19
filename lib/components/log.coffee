component = require '../etl-component'

module.exports = component
  write: (data, cb) ->
    print = if @options.sync then console.error else console.log
    print @options.prefix, data
    cb null
