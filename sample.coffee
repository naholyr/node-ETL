components = require './lib/components'

[csv, transform, log] = components.load 'csv', 'transform', 'log'


sample1 = ->

csv
  file: "random-numbers.csv"
  delimiter: ","

  -> transform
    clone: true
    mapping:
      sum:  (row) -> row.rnd + row.count
      diff: (row) -> row.rnd - row.count

    -> log
      prefix: 'transformed: '

  -> log
    prefix: 'original: '



# Alternatively, declaring your input/outputs and branching them later should work

sample2 = ->

  input = csv
    file: "random-numbers.csv"
    delimiter: ","

  map = transform
    clone: true
    mapping:
      sum:  (row) -> row.rnd + row.count
      diff: (row) -> row.rnd - row.count

  out_transformed = log
    prefix: 'transformed(2): '

  out_original = log
    prefix: 'original(2): '

  # Branching
  input -> [
    out_original,
    map -> out_transformed
  ]



setTimeout sample1, 0
setTimeout (-> console.log '---------------------'), 200
setTimeout sample2, 250
