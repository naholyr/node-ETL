module.exports =
  load: (names...) ->
    components = (require './' + name for name in names)
    if arguments.length == 1 then components[0] else components
