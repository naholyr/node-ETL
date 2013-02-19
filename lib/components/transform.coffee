component = require '../etl-component'

module.exports = component
  transform: (data, emit, done) ->
    res = {}

    if @options?.clone
      res[prop] = data[prop] for prop of data

    if @options?.mapping
      res[prop] = @options.mapping?[prop] data for prop of @options.mapping

    emit res

    done null
