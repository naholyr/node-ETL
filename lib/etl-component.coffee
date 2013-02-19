# The declarative way is simple:
# Component :: Object -> Duplex
#
# The chained way is a bit trickier:
# Component :: Object -> Duplex... -> Duplex

# So an ETL component is a function taking some options and returning a Duplex
# A "Duplex" is itself a function accepting other Duplex(es) as parameter
#
# Note: in fact, a Duplex can also be a function directly returning the real Duplex
# This is a shortcut to simplify description, but allows the nice arrow-syntax using coffee
#
# How it's supposed to work:
# input(output) will send every data of Duplex "input" to "output"
# input(input_output1(input_output2(output))) will send every data of Duplex "input" to "input_output1", then every output of "input_output1" as input of "input_output2", then every output of the latter to "output".
#
# We need streams. OK let's say a Duplex has a property "stream", always.
#
# How duplex receives data: Duplex::stream.writable is true
# How duplex emits data: Duplex::stream.readable is true and it just emits the stream way

# OK let's go

Stream = require 'stream'

create_component = module.exports = (stream_options = {}) ->
  LocalStream = ETLStream stream_options
  return (options, outs...) ->
    connect = (target) ->
      if Array.isArray target
        component.apply component, target
      else if not target.stream
        connect target()
      else
        component.stream.pipe target.stream
    component = (targets...) ->
      connect target for target in targets
      return component
    component.stream = new LocalStream options
    component outs

ETLStream = (options) ->
  if options.transform
    return ETLStreamTransform options.init, options.transform, options.stream_options
  else if options.read and options.write
    return ETLStreamInputOutput options.init, options.read, options.write, options.stream_options
  else if options.read
    return ETLStreamInput options.init, options.read, options.stream_options
  else if options.write
    return ETLStreamOutput options.init, options.write, options.stream_options
  else if options.stream
    return options.stream
  else
    throw new Error 'Invalid stream description'

ETLStreamInputOutput = (init, read, write, options = {}) ->
  class InputOutput extends Stream.Duplex
    constructor: (_options = {}) ->
      super options
      @options = _options
      init?.call? this, _options
    _read: (bytes, cb) ->
      process.nextTick read.bind this, bytes, cb
    _write: (data, cb) ->
      write.call this data cb

ETLStreamInput = (init, read, options = {}) ->
  class Input extends Stream.Readable
    constructor: (_options = {}) ->
      super options
      @options = _options
      init?.call? this, _options
    _read: (bytes, cb) ->
      process.nextTick read.bind this, bytes, cb

ETLStreamOutput = (init, write, options = {}) ->
  class Output extends Stream.Writable
    constructor: (_options = {}) ->
      super options
      @options = _options
      init?.call? this, _options
    _write: (data, cb) ->
      write.call this, data, cb

ETLStreamTransform = (init, transform, options = {}) ->
  class Transform extends Stream.Transform
    constructor: (_options = {}) ->
      super options
      @options = _options
      init?.call? this, _options
    _transform: (data, emit, done) ->
      transform.call this, data, emit, done
